#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Counter {
    #[key]
    entityId: u32,
    counter: u32
}
