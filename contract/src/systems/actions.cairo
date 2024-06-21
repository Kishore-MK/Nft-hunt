use dojo_starter::models::{player::{Character},move::MoveType, walk::Direction};
use dojo_starter::models::position::Position;


use dojo::world::{IWorldDispatcher, IWorldDispatcherImpl, IWorldDispatcherTrait};

use dojo_starter::models::map::MapTraits;

#[dojo::interface]
trait IActions{
    fn moved(ref world: IWorldDispatcher, direction: Direction);
    fn spawn(ref world: IWorldDispatcher,character: Character);
    fn action(ref world: IWorldDispatcher,Move: MoveType);
    
}
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address, contract_address_const};
    use dojo_starter::models::{
        health::Health, player::{Player, Character},move::{Move,MoveType},game::{Game, GameStatus, GameStatusImplTrait}, counter::{Counter}, treasure::{Treasure,Location},map::Map,walk::Direction
    };
    use dojo_starter::token::erc20::ERC20::{mint};
    use dojo_starter::models::position::{Position , next_position};
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
        player: ContractAddress,
        direction: Direction
    }


    #[derive(Drop, Serde, starknet::Event)]
    struct CharacterAction {
        player: ContractAddress,
        action: MoveType,
        moveValue: u16
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
            let pos=Position{x:0,y:0,z:0};

            set!(
                world,
                (
                    Player { player, character, score: playerStatus.score,position: pos },
                    Game { player, entityId: gameCounter, status: GameStatus::InProgress },
                    Health { entityId: player, gameId: gameCounter, health: 100 },
                    Move { entityId: player, gameId: gameCounter, attack, healing },
                )
            );

            set!(
                world,
                (
                    Health {
                        entityId: contract_address_const::<SLIME_ID>(),
                        gameId: gameCounter,
                        health: 60
                    },
                    Move {
                        entityId: contract_address_const::<SLIME_ID>(),
                        gameId: gameCounter,
                        healing: 10,
                        attack: 20,
                    },
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
        

        fn action(ref world: IWorldDispatcher, Move: MoveType) {
            let player = get_caller_address();
            let (mut playerCharacter, mut gameStatus) = get!(world, player, (Player, Game));

            let (mut playerHealth, playerMove) = get!(
                world, (player, gameStatus.entityId), (Health, Move)
            );

            let (mut slimeHealth, slimeMove) = get!(
                world,
                (contract_address_const::<SLIME_ID>(), gameStatus.entityId),
                (Health, Move)
            );

            let mut treasureHealth = get!(
                world,
                (contract_address_const::<TREASURE_ID>(), gameStatus.entityId),
                (Health)
            );

            gameStatus.assert_in_progress();
            let mut moveValue: u16 = 0;
            match Move {
                MoveType::attack => {
                    moveValue = playerMove.attack;
                    if slimeHealth.health > playerMove.attack {
                        slimeHealth.health -= playerMove.attack
                    } else {
                        slimeHealth.health = 0;
                        playerCharacter.score += 10;
                        set!(world, (playerCharacter, gameStatus))
                    }

                    if(player.position.x<=Location.x+10 && player.position.y<=Location.y+10 && player.position.y<=Location.z+10 && player.position.x>=Location.x-10 && player.position.y>=Location.y-10 && player.position.y>=Location.y-10 && player.position.y>=Location.z-10){
                        if treasureHealth.health > playerMove.attack {
                            treasureHealth.health -= playerMove.attack
                        } else {
                            treasureHealth.health = 0;
                            playerCharacter.score += 100;
                            gameStatus.status = GameStatus::Won;
                            set!(world, (playerCharacter, gameStatus))
                        }

                    }
                    set!(world, (slimeHealth))
                    set!(world, (treasureHealth))
                },
                
                MoveType::healing => {
                    moveValue = playerMove.healing;
                    playerHealth.health += playerMove.healing;
                    set!(world, (playerHealth))
                }
            }
            emit!(world,(Event::CharacterAction(CharacterAction { player, action: Move, moveValue })));

            if slimeHealth.health > 0 {
                if playerHealth.health > slimeMove.attack {
                    playerHealth.health -= slimeMove.attack;
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
                            action: MoveType::attack,
                            moveValue: slimeMove.attack
                        }
                    ))
                );
            }
        }
        

        fn moved(ref world: IWorldDispatcher, direction: Direction) {
            let player = get_caller_address();

            let mut playerPosition = get!(world, player, (Player));
            let newPosition = next_position(playerPosition.position, direction);

            assert(Map::is_valid_map_position(position: newPosition), 'Position outside map');
            assert(Map::is_walkable_position(position: newPosition), 'Not walkable position');

            playerPosition.position = newPosition;

            set!(world,(playerPosition));

            emit!(world,(Event::PositionAction(Moved { player, direction })));
        }
    }
}
