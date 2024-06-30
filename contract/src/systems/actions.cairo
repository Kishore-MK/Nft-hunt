use dojo_starter::models::{player::{Character},action::ActionType, walk::Direction, treasure::{Treasure,Location}};



use dojo::world::{IWorldDispatcher, IWorldDispatcherImpl, IWorldDispatcherTrait};


#[dojo::interface]
trait IActions{
    // fn moved(ref world: IWorldDispatcher, direction: Direction);
    fn spawn(ref world: IWorldDispatcher,character: Character);
    fn action(ref world: IWorldDispatcher,Action: ActionType, location: Location);
    
}
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address, contract_address_const};
    use dojo_starter::models::{
        health::Health, player::{Player, Character},action::{Action, ActionType},game::{Game, GameStatus, GameStatusImplTrait}, counter::{Counter}, treasure::{Treasure,TreasureStatus,Location},walk::Direction
    };
 
    // use dojo::world::{IWorldDispatcher, IWorldDispatcherImpl, IWorldDispatcherTrait};


    const TREASURE_ID: felt252 = 0x878f26c5e;
    const SLIME_ID: felt252 = 0x676f626c696e;
    const COUNTER_ID: u32 = 999999999;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CharacterAction: CharacterAction,
        PositionAction: Moved,
    }
    
    #[derive(Drop, Serde, starknet::Event)]
    struct Moved {
        #[key]
        player: ContractAddress,
        direction: Direction
    }


    #[derive(Drop, Serde, starknet::Event)]
    struct CharacterAction {
        #[key]
        player: ContractAddress,
        action: ActionType,
        ActionValue: u16
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn spawn(ref world: IWorldDispatcher, character: Character) {
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();
            let mut attack: u16 = 0;
            let mut healing: u16 = 0;

            let playerStatus = get!(world, player, (Player));

            let currentCounter = get!(world, COUNTER_ID, (Counter));
            let gameCounter = currentCounter.counter + 1;

            match character {
                Character::Hunter => {
                    attack = 10;
                    healing = 25;
                }
            }
           
            let loc=Location{x:20,y:14,z:0};
            set!(
                world,
                (
                    Player { player, character, score: playerStatus.score },
                    Game { player, entityId: gameCounter, status: GameStatus::InProgress },
                    Health { entityId: player, gameId: gameCounter, health: 100 },
                    Action { entityId: player, attack, healing },
                    Treasure {player, location: loc, claim: TreasureStatus::not_claimed},
                )
            );

           
            set!(
                world,
                (
                    Health {
                        entityId: contract_address_const::<TREASURE_ID>(),
                        gameId: gameCounter,
                        health: 600
                    }
                )
            );

            set!(world, (Counter { entityId: COUNTER_ID, counter: gameCounter }));
        }
        

        fn action(ref world: IWorldDispatcher, Action: ActionType, location: Location) {
            let player = get_caller_address();
            let (mut playerCharacter, mut gameStatus, mut treasure_status) = get!(world, player,(Player, Game, Treasure));

            let (mut playerHealth, playerAction) = get!(
                world, (player, gameStatus.entityId), (Health, Action)
            );

            let (mut slimeHealth, slimeAction) = get!(
                world,
                (contract_address_const::<SLIME_ID>(), gameStatus.entityId),
                (Health, Action)
            );

            let mut treasureHealth = get!(
                world,
                (contract_address_const::<TREASURE_ID>(), gameStatus.entityId),
                (Health)
            );

            gameStatus.assert_in_progress();
            let mut ActionValue: u16 = 0;
            match Action {
                ActionType::attack => {
                    ActionValue = playerAction.attack;
                    if slimeHealth.health > playerAction.attack {
                        slimeHealth.health -= playerAction.attack
                    } else {
                        slimeHealth.health = 0;
                        playerCharacter.score += 10;
                        set!(world, (playerCharacter, gameStatus))
                    }

                    
                    set!(world, (slimeHealth));
                    set!(world, (treasureHealth))
                },
                
                ActionType::healing => {
                    ActionValue = playerAction.healing;
                    playerHealth.health += playerAction.healing;
                    set!(world, (playerHealth))
                }
            }
            emit!(world,(Event::CharacterAction(CharacterAction { player, action: Action, ActionValue })));

            if slimeHealth.health > 0 {
                if playerHealth.health > slimeAction.attack {
                    playerHealth.health -= slimeAction.attack;
                } else {
                    playerHealth.health = 0;
                    gameStatus.status = GameStatus::Lost;
                    set!(world, (gameStatus));
                };

                set!(world, (playerHealth));
                emit!(
                    world,
                    (Event::CharacterAction(
                        CharacterAction {
                            player: contract_address_const::<SLIME_ID>(),
                            action: ActionType::attack,
                            ActionValue: slimeAction.attack
                        }
                    ))
                );
            }
        }
        

        // fn moved(ref world: IWorldDispatcher, direction: Direction) {
        //     let player = get_caller_address();

        //     let mut playerPosition = get!(world, player, (Player));
        //     let newPosition = next_position(playerPosition.position, direction);

            
        //     playerPosition.position = newPosition;

        //     set!(world,(playerPosition));

        //     emit!(world,(Event::PositionAction(Moved { player, direction })));
        // }
    }
}
