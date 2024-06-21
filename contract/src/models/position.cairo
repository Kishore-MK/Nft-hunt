use dojo_starter::models::walk::Direction;

#[derive(Copy, Drop, Serde, Introspect)]
struct Position {

    x: u32,
    y: u32,
    z: u32,
}

fn next_position(mut pos: Position, direction: Direction) -> Position {
    match direction {
        Direction::Left => { pos.x -= 1; },
        Direction::Right => {pos.x += 1; },
        Direction::Up => { pos.y -= 1; },
        Direction::Down => { pos.y += 1; },
    };
    pos
}