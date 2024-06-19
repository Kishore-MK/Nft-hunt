use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Move {
    #[key]
    entityId: ContractAddress,
    #[key]
    gameId: u32,
    attack: u16,
    healing: u16
}

#[derive(Serde, Copy, Drop, Introspect)]
enum MoveType {
    
    attack,
    healing,
}

impl MoveTypeIntoFelt252 of Into<MoveType, felt252> {
    fn into(self: MoveType) -> felt252 {
        match self {
            MoveType::attack => 1,
            MoveType::healing => 2,
        }
    }
}
