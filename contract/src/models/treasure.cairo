use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Introspect)]
#[dojo::model]
struct Treasure {
    #[key]
    player: ContractAddress,
    location: Location,
    claim: TreasureStatus,
    

}

#[derive(Serde, Copy, Drop, Introspect)]
enum Location{
    x:u32,
    y:u32,
    z:u32
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum TreasureStatus {
    claimed: (),
    not_claimed: (),
}


impl TreasureFelt252 of Into<TreasureStatus, felt252> {
    fn into(self: TreasureStatus) -> felt252 {
        match self {
            TreasureStatus::claimed => 1,
            TreasureStatus::not_claimed => 2,
        }
    }
}



#[generate_trait]
impl TreasureImpl of TreasureImplTrait {
    // Asserts that the game is in progress
    fn treasure_notclaimed(self: Treasure) {
        assert(self.claim== TreasureStatus::not_claimed, 'Reward not claimed');
    }

    // Asserts that the game is in the lobby
    fn treasure_claimed(self: Treasure) {
        assert(self.claim == TreasureStatus::claimed, 'Reward claimed');
    }
}