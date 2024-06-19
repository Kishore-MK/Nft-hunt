use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Health {
    #[key]
    entityId: ContractAddress,
    #[key]
    gameId: u32,
    health: u16,
}

