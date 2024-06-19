use dojo_starter::models::{player::Character,move::MoveType};
use dojo::world::{IWorldDispatcher, IWorldDispatcherImpl, IWorldDispatcherTrait};

#[dojo::interface]
trait IActions{
    fn spawn(ref world: IWorldDispatcher,character: Character);
    fn action(ref world: IWorldDispatcher,Move: MoveType);
}
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address, contract_address_const};
    use dojo_starter::models::{
        health::Health, player::{Player, Character},move::{Move,MoveType},game::{Game, GameStatus, GameStatusImplTrait}, counter::{Counter}
    };
    
    const SLIME_ID: felt252 = 0x676f626c696e;
    const COUNTER_ID: u32 = 999999999;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CharacterAction: CharacterAction,
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
                    attack = 15;
                    healing = 25
                }
            }

            set!(
                world,
                (
                    Player { player, character, score: playerStatus.score },
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
                        health: 100
                    },
                    Move {
                        entityId: contract_address_const::<SLIME_ID>(),
                        gameId: gameCounter,
                        healing: 10,
                        attack: 20,
                    },
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
                    set!(world, (slimeHealth))
                },
                
                MoveType::healing => {
                    moveValue = playerMove.healing;
                    playerHealth.health += playerMove.healing;
                    set!(world, (playerHealth))
                }
            }
            emit!(
                world,
                (Event::CharacterAction(CharacterAction { player, action: Move, moveValue }))
            );

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
    }
}
