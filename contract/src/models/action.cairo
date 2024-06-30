use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Action {
    #[key]
    entityId: ContractAddress,
    attack: u16,
    healing: u16
}

#[derive(Serde, Copy, Drop, Introspect)]
enum ActionType {
    attack,
    healing,
}

impl ActionTypeIntoFelt252 of Into<ActionType, felt252> {
    fn into(self: ActionType) -> felt252 {
        match self {
            ActionType::attack => 1,
            ActionType::healing => 2,
        }
    }
}
