import HashMap "mo:base/HashMap";

module Reference = {

    // ----------------------------------
    // TYPES
    // ----------------------------------

    public type Position = {
        x: Float;
        y: Float;
    };

    public type Market = {
        id: Nat16;               // id used internally
        name: Text;              // name of the market for readability
        items: [Nat16];          // item ids available at the market
    };

    public type Item = {
        id: Nat16;               // id used internally
        name: Text;              // name of the event for readability
        metadata: [Nat8];        // metadata for the item (to mint it)
        unityId: Text;           // id used by unity (for parsing and generating save data)
        ableClasses: [Nat8];     // list of class indices able to equp/use the item
        minLevel: Nat16;         // minimum level for someone to equip/use this item
    };

    public type Monster = {
        id: Nat16;               // id used internally
        name: Text;              // name of the event for readability
        gold: Nat32;             // gold rewarded by monster
        xp: Nat32;               // xp rewarded by monster
    };

    public type TreasureChest = {
        id: Nat16;               // id used internally
        gold: Nat32;             // gold rewarded by monster
        prerequisites: [Nat16];  // all prerequisites Plot Events that must be completed before receiving the chest
        position: ?Position;     // rough position player should be in to open chest
    };

    // note: opening a treasure chest may in fact be a plot event. In these cases the plot event should not award anything: the chest will;
    public type PlotEvent = {
        id: Nat16;               // id used internally
        name: Text;              // name of the event for readability
        items: [Nat16];          // item ids that should be awarded upon completion
        gold: Nat32;             // gold amount that should be awarded upon completion
        prerequisites: [Nat16];  // all prerequisites Plot Events that must be completed before completing this plot event
        position: ?Position;     // rough position player should be in to complete
    };

    // ----------------------------------
    // GAME REFERENCE DATA
    // ----------------------------------

    public let markets : [Market] = [
        {id=0; name="Chapter 1 Market"; items=[0,1,2,3]},
    ];

    public let monsters : [Monster] = [
        {id=0; name="Slurghog"; gold=5; xp=4},
    ];

    public let items : [Item] = [
        // Weapons
        { id=0; name="test name 1"; metadata=[1,1,1]; unityId="test0"; ableClasses=[1]; minLevel=2 },
        { id=1; name="test name 2"; metadata=[0,1,1]; unityId="test1"; ableClasses=[1]; minLevel=1 },
        { id=2; name="test name 3"; metadata=[0,1,1]; unityId="test2"; ableClasses=[1]; minLevel=0 },
        { id=3; name="test name 4"; metadata=[0,1,1]; unityId="test3"; ableClasses=[2]; minLevel=3 },
    ];
    
    public let chests : [TreasureChest] = [
        { id=0; gold=20; prerequisites=[0]; position=?{x=1.0;y=1.0} },
        { id=1; gold=10; prerequisites=[1]; position=?{x=1.0;y=1.0} },
        { id=2; gold=10; prerequisites=[]; position=?{x=100.0;y=1.0} },
        { id=3; gold=10; prerequisites=[]; position=?{x=1.0;y=1.0} },
    ];

    public let prerequisites : [PlotEvent] = [
        { id=0; name="talk to granny"; gold=0; items=[]; prerequisites=[]; position=?{x=1.0;y=1.0}},
        { id=1; name="get weapons"; gold=0; items=[0,1]; prerequisites=[]; position=?{x=30.0;y=30.0}},
    ];
};