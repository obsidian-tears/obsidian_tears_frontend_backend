import HashMap "mo:base/HashMap";

module Reference = {

    // ----------------------------------
    // TYPES
    // ----------------------------------

    public type Position = {
        x: Float;
        y: Float;
    };

    public type ItemReward = {
        #RandomItem : {
            tier: Nat8;
        };
        #SpecificItem : {
            items: [Nat16];
        };
        #None;
    };

    public type Market = {
        id: Nat16;               // id used internally
        name: Text;              // name of the market for readability
        items: [ItemListing];    // item listings available at the market
    };

    public type Item = {
        id: Nat16;               // id used internally
        name: Text;              // name of the event for readability
        metadata: [Nat8];        // metadata for the item (to mint it)
        unityId: Text;           // id used by unity (for parsing and generating save data)
        ableClasses: [Nat8];     // list of class indices able to equp/use the item (based on character metadata)
        tier: Nat8;              // tier. determines minimum level for someone to equip/use this item
    };

    public type ItemListing = {
        id: Nat16;
        cost: Nat32;
    };

    public type Tier = {
        number: Nat8;
        minLevel: Nat16;
    };

    public type Monster = {
        id: Nat16;               // id used internally
        name: Text;              // name of the event for readability
        gold: Nat32;             // gold rewarded by monster
        xp: Nat32;               // xp rewarded by monster
        itemReward: ItemReward;  // what kind of items will you get
        itemProb: Nat8;         // what kind of items will you get
    };

    public type TreasureChest = {
        id: Nat16;               // id used internally
        name: Text;              // 
        gold: Nat32;             // gold rewarded by monster
        itemReward: ItemReward;  // what kind of items will you get
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
        {id=0; name="Chapter 1 Market"; 
        items=[
            {id=0; cost=100;},
            {id=1; cost=200;},
            {id=2; cost=300;},
            {id=3; cost=400;}
            ]},
    ];

    public let tiers : [Tier] = [
        {number=1; minLevel=0;},
        {number=2; minLevel=5;},
        {number=3; minLevel=10;},
    ];


    public let items : [Item] = [
        { id=0; name="Orb of Passing";        unityId="1629230594";   metadata=[];      ableClasses=[];      tier=1 }, // non nft item
        { id=1; name="Amethyst Pendant";      unityId="1931403643";   metadata=[1,1,1]; ableClasses=[0,1,2]; tier=1 }, // nft item
        { id=2; name="Blue Leaf Ring";        unityId="481000799";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=3; name="The Blade of the Sun";  unityId="3253817716";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=4; name="Woodlands Magic Staff"; unityId="2564641913";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=5; name="Iron Chestplate";       unityId="653732320";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=6; name="Dwarven Battleaxe";     unityId="1037042359";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=7; name="Fire Katana";           unityId="418848405";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=8; name="Blue Potion Full";      unityId="2855010320";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=9; name="Half Blue Potion";      unityId="484278545";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=10; name="Red Potion Full";      unityId="1722848991";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=11; name="Half Red Potion";      unityId="1037437805";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=12; name="Yam";                  unityId="3366400426";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=13; name="Knight Helmet";        unityId="4289281774";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=14; name="Leather Boots";        unityId="1081105223";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=15; name="Leather Helmet";       unityId="1280933307";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
        { id=16; name="Rune of Doom";         unityId="1144956306";   metadata=[];      ableClasses=[];      tier=1 },
        { id=17; name="Fire Wand";            unityId="2148976045";   metadata=[];      ableClasses=[];      tier=1 },
        { id=18; name="Wizard Wand";          unityId="3232140955";   metadata=[];      ableClasses=[];      tier=1 },
        { id=19; name="Monster Jaw";          unityId="3666317515";   metadata=[];      ableClasses=[];      tier=1 },
        { id=20; name="Wooden Sword";         unityId="2069047119";   metadata=[];      ableClasses=[];      tier=1 },
        { id=21; name="Bow";                  unityId="363272315";    metadata=[2,3,4]; ableClasses=[];      tier=1 },
        { id=22; name="Blades of Duality";    unityId="2847687731";   metadata=[0,1,2]; ableClasses=[0,1,2]; tier=1 },
        { id=23; name="Iron Sword";           unityId="976575711";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    ];


    public let monsters : [Monster] = [
        { id=0; name="Ghost";   gold=0; xp=100; itemReward=#SpecificItem({items = [99, 99]}); itemProb=100},
        { id=1; name="Zombie";  gold=0; xp=100; itemReward=#RandomItem({tier = 2});           itemProb=10},
    ];

    public let chests : [TreasureChest] = [
        { id=0; name="2 full mana potions";             gold=0;  itemReward=#SpecificItem({items = [99, 99]});             prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=1; name="Fire Katana";                     gold=0;  itemReward=#SpecificItem({items = [99]});                 prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=2; name="Gold by Corn 25";                 gold=25; itemReward=#SpecificItem({items = [99]});                 prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=3; name="Gold by Corn 10";                 gold=10; itemReward=#SpecificItem({items = [99]});                 prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=4; name="5 full red potions";              gold=0;  itemReward=#SpecificItem({items = [99, 99, 99, 99, 99]}); prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=5; name="Tier 2 Overworld 1";              gold=0;  itemReward=#RandomItem({tier = 2});                      prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=6; name="Tier 2 Overworld 2";              gold=0;  itemReward=#RandomItem({tier = 2});                      prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=7; name="Tier 2 Overworld 3";              gold=0;  itemReward=#RandomItem({tier = 2});                      prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=8; name="Tier 2 Overworld 4";              gold=0;  itemReward=#RandomItem({tier = 2});                      prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=9; name="Tier 2 Overworld 5";              gold=0;  itemReward=#RandomItem({tier = 2});                      prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=10; name="Splash";                         gold=0;  itemReward=#SpecificItem({items = [99]});                 prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=11; name="Tier 2 City Corner";             gold=0;  itemReward=#RandomItem({tier = 2});                      prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=12; name="Tier 3 Platform Over Water";     gold=0;  itemReward=#RandomItem({tier = 2});                      prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=13; name="Gold by Lake 10";                gold=10; itemReward=#None;                               prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=14; name="Tier 3 in Skull Trees";          gold=0;  itemReward=#RandomItem({tier = 3});                      prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=15; name="Amethyst Pendant";               gold=0;  itemReward=#SpecificItem{items = ([99])};                 prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=16; name="Tier 3 in Dead Trees";           gold=0;  itemReward=#RandomItem({tier = 3});                      prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=17; name="Gold Below Obelisk Platform 15"; gold=15; itemReward=#None;                               prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=18; name="2 yams";                         gold=0;  itemReward=#SpecificItem({items = [99, 99]});             prerequisites=[]; position=?{x=1.0;y=1.0} },
        { id=19; name="Bread";                          gold=0;  itemReward=#SpecificItem({items = [99]});                 prerequisites=[]; position=?{x=1.0;y=1.0} },
    ];

    public let events : [PlotEvent] = [
        { id=0; name="Find Rune of Doom";   gold=0; items=[];   prerequisites=[];      position=?{x=1.0;y=1.0}},
        { id=1; name="Find Wizard Wand";    gold=0; items=[];   prerequisites=[];      position=?{x=30.0;y=30.0}},
        { id=2; name="Find Orb of Passing"; gold=0; items=[];   prerequisites=[];      position=?{x=30.0;y=30.0}},
        { id=3; name="Pond Cave";           gold=0; items=[];   prerequisites=[];      position=?{x=30.0;y=30.0}},
        { id=4; name="Hidden Path Cave";    gold=0; items=[];   prerequisites=[];      position=?{x=30.0;y=30.0}},
        { id=5; name="Blades from Tiana";   gold=0; items=[22]; prerequisites=[0,1,2]; position=?{x=30.0;y=30.0}},
        { id=6; name="Find Monster Jaw";    gold=0; items=[22]; prerequisites=[0,1,2]; position=?{x=30.0;y=30.0}},
        { id=7; name="Bow from Archer";     gold=0; items=[21]; prerequisites=[6];     position=?{x=30.0;y=30.0}},
        { id=8; name="Sword from Herl";     gold=0; items=[23]; prerequisites=[];      position=?{x=30.0;y=30.0}},
    ];
};