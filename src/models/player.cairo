use starknet::ContactAddress
const TIME_BETWEEN_ACTIONS: u64 = 120;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    address: starknet::ContractAddress,
    player: felt252,
    socre: u64
}

#[derive(Serde, Copy, Drop, Introspect)]
enum Character {
    Player,
}

impl CharacterIntoFelt252 of Into<Character, felt252> {
    fn into(self: Character) -> felt252 {
        match self {
            Character::Player =>1,
        }
    }
}
