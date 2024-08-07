// Generated by dojo-bindgen on Mon, 1 Jul 2024 11:39:24 +0000. Do not modify this file manually.
using System;
using Dojo;
using Dojo.Starknet;
using System.Reflection;
using System.Linq;
using System.Collections.Generic;
using Enum = Dojo.Starknet.Enum;

// Type definition for `core::byte_array::ByteArray` struct
[Serializable]
public struct ByteArray {
    public string[] data;
    public FieldElement pending_word;
    public uint pending_word_len;
}

// Type definition for `core::option::Option::<core::integer::u32>` enum
public abstract record Option<A>() : Enum {
    public record Some(A value) : Option<A>;
    public record None() : Option<A>;
}


// Model definition for `dojo_starter::models::health::Health` model
public class Health : ModelInstance {
    [ModelField("entityId")]
    public FieldElement entityId;

    [ModelField("gameId")]
    public uint gameId;

    [ModelField("health")]
    public ushort health;

    // Start is called before the first frame update
    void Start() {
    }

    // Update is called once per frame
    void Update() {
    }
}
        