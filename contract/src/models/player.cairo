use starknet::ContractAddress;
use dojo_starter::models::walk::Direction;
#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    player: ContractAddress,
    character: Character,
    score: u64
    
}



#[derive(Serde, Copy, Drop, Introspect)]
enum Character {
    Hunter,
}

impl CharacterIntoFelt252 of Into<Character, felt252> {
    fn into(self: Character) -> felt252 {
        match self {
            Character::Hunter =>1,
        }
    }
}
