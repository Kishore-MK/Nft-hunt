
#[derive(Drop, Copy, Serde)]
#[dojo::model]
struct MapObject {
    #[key]
    player: ContractAddress,
    position: Position,
}



use dojo::world::{IWorldDispatcher, IWorldDispatcherImpl};
use starknet::{ContractAddress};
use dojo_starter::models::player::{Position};



#[generate_trait]
impl Map of MapTraits {
    
    fn is_valid_map_position(position: Position) -> bool {
        return true;
    }

    fn is_walkable_position(position: Position) -> bool {
        return true;
    }
} 