use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Game {
    #[key]
    player: ContractAddress,
    entityId: u32,
    status: GameStatus
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
// Define an enum representing different states of a game
enum GameStatus {
    Lobby: (),
    InProgress: (),
    Lost: (),
    Won: ()
}

impl GameStatusFelt252 of Into<GameStatus, felt252> {
    // Converts a GameStatus variant to its corresponding `felt252` value
    fn into(self: GameStatus) -> felt252 {
        match self {
            GameStatus::Lobby => 1,
            GameStatus::InProgress => 2,
            GameStatus::Lost => 3,
            GameStatus::Won => 4
        }
    }
}

#[generate_trait]
impl GameStatusImpl of GameStatusImplTrait {
    // Asserts that the game is in progress
    fn assert_in_progress(self: Game) {
        assert(self.status == GameStatus::InProgress, 'Game not started');
    }

    // Asserts that the game is in the lobby
    fn assert_lobby(self: Game) {
        assert(self.status == GameStatus::Lobby, 'Game not in lobby');
    }
}

