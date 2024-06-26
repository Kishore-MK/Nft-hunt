// Generated by dojo-bindgen on Mon, 1 Jul 2024 11:39:24 +0000. Do not modify this file manually.
using System;
using Dojo;
using Dojo.Starknet;
using System.Reflection;
using System.Linq;
using System.Collections.Generic;
using Enum = Dojo.Starknet.Enum;

// Type definition for `dojo_starter::models::treasure::Location` struct
[Serializable]
public struct Location {
    public uint x;
    public uint y;
    public uint z;
}

// Type definition for `dojo_starter::models::treasure::TreasureStatus` enum
public abstract record TreasureStatus() : Enum {
    public record claimed() : TreasureStatus;
    public record not_claimed() : TreasureStatus;
}


// Model definition for `dojo_starter::models::treasure::Treasure` model
public class Treasure : ModelInstance {
    [ModelField("player")]
    public FieldElement player;

    [ModelField("location")]
    public Location location;

    [ModelField("claim")]
    public TreasureStatus claim;

    // Start is called before the first frame update
    void Start() {
    }

    // Update is called once per frame
    void Update() {
    }
}
        