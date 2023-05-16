import HashMap "mo:base/HashMap";

module Reference = {

  // ----------------------------------
  // TYPES
  // ----------------------------------

  public type Position = {
    x : Float;
    y : Float;
  };

  public type ItemReward = {
    #RandomItem : {
      tier : Nat8;
    };
    #SpecificItem : {
      items : [Nat16];
    };
    #None;
  };

  public type Market = {
    id : Nat16; // id used internally
    name : Text; // name of the market for readability
    items : [ItemListing]; // item listings available at the market
  };

  public type Item = {
    id : Nat16; // id used internally
    name : Text; // name of the event for readability
    metadata : [Nat8]; // metadata for the item (to mint it)
    unityId : Text; // id used by unity (for parsing and generating save data)
    ableClasses : [Nat8]; // list of class indices able to equp/use the item (based on character metadata)
    tier : Nat8; // tier. determines minimum level for someone to equip/use this item
  };

  public type ItemListing = {
    id : Nat16;
    cost : Nat32;
  };

  public type Tier = {
    number : Nat8;
    minLevel : Nat16;
  };

  public type Monster = {
    id : Nat16; // id used internally
    name : Text; // name of the event for readability
    gold : Nat32; // gold rewarded by monster
    xp : Nat32; // xp rewarded by monster
    itemReward : ItemReward; // what kind of items will you get
    itemProb : Nat8; // what kind of items will you get
  };

  public type TreasureChest = {
    id : Nat16; // id used internally
    name : Text; //
    gold : Nat32; // gold rewarded by monster
    itemReward : ItemReward; // what kind of items will you get
    prerequisites : [Nat16]; // all prerequisites Plot Events that must be completed before receiving the chest
    position : ?Position; // rough position player should be in to open chest
  };

  // note: opening a treasure chest may in fact be a plot event. In these cases the plot event should not award anything: the chest will;
  public type PlotEvent = {
    id : Nat16; // id used internally
    name : Text; // name of the event for readability
    items : [Nat16]; // item ids that should be awarded upon completion
    gold : Nat32; // gold amount that should be awarded upon completion
    prerequisites : [Nat16]; // all prerequisites Plot Events that must be completed before completing this plot event
    position : ?Position; // rough position player should be in to complete
  };

  // ----------------------------------
  // GAME REFERENCE DATA
  // ----------------------------------

  /*
    Ardvan Town Square Market
    Apple                                     4
    Bread                                    10
    Extraordinarily big stick                 1
    Yam                                      15

    Blacksmith West Gate Market
    Iron Helmet                              50
    Iron Chestplate                          55
    Metal Boots                              40
    Iron Sword                               35

    Tabitha Potion Shop
    Blue Potion Full                          6
    Half Blue Potion                          3
    Red Potion Full                           6
    Half Red Potion                           3
    Firedrain spell                          23
    Smokescreen spell                        55
    */

  public let markets : [Market] = [
    {
      id = 0;
      name = "Ardvan Town Square Market";
      items = [
        { id = 27; cost = 4 },
        { id = 32; cost = 10 },
        { id = 38; cost = 1 },
        { id = 92; cost = 15 },
      ];
    },
    {
      id = 1;
      name = "Blacksmith West Gate Market";
      items = [
        { id = 49; cost = 50 },
        { id = 48; cost = 55 },
        { id = 55; cost = 40 },
        { id = 50; cost = 35 },
      ];
    },
    {
      id = 2;
      name = "Tabitha Potion Shop";
      items = [
        { id = 30; cost = 6 },
        { id = 46; cost = 3 },
        { id = 68; cost = 6 },
        { id = 47; cost = 3 },
        { id = 41; cost = 23 },
        { id = 74; cost = 55 },
      ];
    },
  ];

  public let tiers : [Tier] = [
    { number = 1; minLevel = 0 },
    { number = 2; minLevel = 5 },
    { number = 3; minLevel = 10 },
  ];

  public let items : [Item] = [
    // { id=0; name="Orb of Passing";        unityId="1629230594";   metadata=[];      ableClasses=[];      tier=1 }, // non nft item
    // { id=1; name="Amethyst Pendant";      unityId="1931403643";   metadata=[1,1,1]; ableClasses=[0,1,2]; tier=1 }, // nft item
    // { id=2; name="Blue Leaf Ring";        unityId="481000799";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=3; name="The Blade of the Sun";  unityId="3253817716";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=4; name="Woodlands Magic Staff"; unityId="2564641913";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=5; name="Iron Chestplate";       unityId="653732320";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=6; name="Dwarven Battleaxe";     unityId="1037042359";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=7; name="Fire Katana";           unityId="418848405";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=8; name="Blue Potion Full";      unityId="2855010320";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=9; name="Half Blue Potion";      unityId="484278545";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=10; name="Red Potion Full";      unityId="1722848991";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=11; name="Half Red Potion";      unityId="1037437805";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=12; name="Yam";                  unityId="3366400426";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=13; name="Knight Helmet";        unityId="4289281774";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=14; name="Leather Boots";        unityId="1081105223";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=15; name="Leather Helmet";       unityId="1280933307";   metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=16; name="Rune of Doom";         unityId="1144956306";   metadata=[];      ableClasses=[];      tier=1 },
    {
      id = 17;
      name = "Fire Wand";
      unityId = "2148976045";
      metadata = [];
      ableClasses = [0, 1, 2];
      tier = 0;
    },
    // { id=18; name="Wizard Wand";          unityId="3232140955";   metadata=[];      ableClasses=[0,1,2];      tier=0 },
    // { id=19; name="Monster Jaw";          unityId="3666317515";   metadata=[];      ableClasses=[];      tier=1 },
    // { id=20; name="Wooden Sword";         unityId="2069047119";   metadata=[];      ableClasses=[];      tier=1 },
    // { id=21; name="Bow";                  unityId="363272315";    metadata=[2,3,4]; ableClasses=[];      tier=1 },
    // { id=22; name="Blades of Duality";    unityId="2847687731";   metadata=[0,1,2]; ableClasses=[0,1,2]; tier=1 },
    // { id=23; name="Iron Sword";           unityId="976575711";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    // { id=24; name="Thors Hammer";         unityId="4030616533";    metadata=[0,1,1]; ableClasses=[0,1,2]; tier=1 },
    {
      id = 25;
      name = "\"Thors Hammer\"";
      unityId = "4030616533";
      metadata = [3, 0, 18, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 26;
      name = "Amethyst Pendant";
      unityId = "1931403643";
      metadata = [3, 2, 3, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 27;
      name = "Apple";
      unityId = "745643686";
      metadata = [3, 2, 12, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 28;
      name = "Black Ribboned Magic Staff";
      unityId = "625332779";
      metadata = [3, 0, 11, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 29;
      name = "Blue Leaf Ring";
      unityId = "481000799";
      metadata = [3, 2, 5, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 30;
      name = "Blue Potion Full";
      unityId = "2855010320";
      metadata = [3, 2, 13, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 31;
      name = "Bow";
      unityId = "363272315";
      metadata = [3, 0, 2, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 32;
      name = "Bread";
      unityId = "1030250569";
      metadata = [3, 2, 14, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 33;
      name = "Bronze Knuckles";
      unityId = "3950828821";
      metadata = [3, 0, 9, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 34;
      name = "Cauldron Lid";
      unityId = "3751818968";
      metadata = [3, 1, 9, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 35;
      name = "Dark Beoite Heart";
      unityId = "4290235510";
      metadata = [3, 2, 15, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 36;
      name = "Dukor's Blade";
      unityId = "2847687731";
      metadata = [3, 0, 0, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 37;
      name = "Dwarven Battle Axe";
      unityId = "1037042359";
      metadata = [3, 0, 7, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 38;
      name = "Extraordinarily Big Stick";
      unityId = "1904791833";
      metadata = [3, 0, 21, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 39;
      name = "Fire Katana";
      unityId = "418848405";
      metadata = [3, 0, 8, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 40;
      name = "Fireblast";
      unityId = "3626749823";
      metadata = [3, 2, 16, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 41;
      name = "FireDrain";
      unityId = "2724998409";
      metadata = [3, 0, 17, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 42;
      name = "Gold Chestplate";
      unityId = "726343602";
      metadata = [3, 1, 2, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 43;
      name = "Gold Helmet";
      unityId = "2655242436";
      metadata = [3, 1, 5, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 44;
      name = "Golden Bow";
      unityId = "3826446335";
      metadata = [3, 0, 3, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 45;
      name = "Green Leaf Ring";
      unityId = "810689207";
      metadata = [3, 2, 6, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 46;
      name = "Half Blue Potion";
      unityId = "484278545";
      metadata = [3, 2, 18, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 47;
      name = "Half Red Potion";
      unityId = "1037437805";
      metadata = [3, 2, 19, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 48;
      name = "Iron Chestplate";
      unityId = "653732320";
      metadata = [3, 1, 3, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 49;
      name = "Iron Helmet";
      unityId = "4289281774";
      metadata = [3, 1, 6, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 50;
      name = "Iron Sword";
      unityId = "976575711";
      metadata = [3, 0, 16, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 51;
      name = "Leather Boots";
      unityId = "1081105223";
      metadata = [3, 1, 1, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 52;
      name = "Leather Helmet";
      unityId = "1280933307";
      metadata = [3, 1, 7, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 53;
      name = "Lu Bu Karma Dagger";
      unityId = "2704662173";
      metadata = [3, 0, 10, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 54;
      name = "Melyn'tyl's Leather Armor";
      unityId = "2303056671";
      metadata = [3, 1, 10, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 55;
      name = "Metal Boots";
      unityId = "1577743681";
      metadata = [3, 1, 11, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 56;
      name = "MeteorStrike";
      unityId = "4240610747";
      metadata = [3, 1, 9, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 57;
      name = "Monster Jaw";
      unityId = "3666317515";
      metadata = [];
      ableClasses = [0, 1, 2];
      tier = 0;
    },
    {
      id = 58;
      name = "Obsidian Boots";
      unityId = "1757689377";
      metadata = [3, 1, 12, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 59;
      name = "Obsidian Bow";
      unityId = "3212510752";
      metadata = [3, 0, 4, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 60;
      name = "Obsidian Chestplate";
      unityId = "27490735";
      metadata = [3, 1, 4, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 61;
      name = "Obsidian Helmet";
      unityId = "1702382863";
      metadata = [3, 1, 8, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 62;
      name = "Obsidian Katana";
      unityId = "1470818698";
      metadata = [3, 0, 1, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 63;
      name = "Pendant of Memories";
      unityId = "2561442878";
      metadata = [];
      ableClasses = [0, 1, 2];
      tier = 0;
    },
    {
      id = 64;
      name = "Pendant of Swiftness";
      unityId = "2777492979";
      metadata = [3, 2, 2, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 65;
      name = "Pendant of Vitality";
      unityId = "2684748356";
      metadata = [3, 2, 4, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 66;
      name = "Pitchfork";
      unityId = "2552016915";
      metadata = [3, 0, 22, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 67;
      name = "Reanimate Essence";
      unityId = "303085544";
      metadata = [3, 0, 20, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 68;
      name = "Red Potion Full";
      unityId = "1722848991";
      metadata = [3, 2, 21, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 69;
      name = "Ring of Quiet Incantation";
      unityId = "4168598264";
      metadata = [3, 0, 7, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 70;
      name = "Rune of Doom";
      unityId = "1144956306";
      metadata = [];
      ableClasses = [0, 1, 2];
      tier = 0;
    },
    {
      id = 71;
      name = "Shard of Light";
      unityId = "677479500";
      metadata = [];
      ableClasses = [0, 1, 2];
      tier = 0;
    },
    {
      id = 72;
      name = "Shield of the Dragon Hearted";
      unityId = "2903559949";
      metadata = [3, 1, 13, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 73;
      name = "Silver Bow";
      unityId = "2714621056";
      metadata = [3, 0, 5, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 74;
      name = "Smokescreen";
      unityId = "1909245789";
      metadata = [3, 2, 10, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 75;
      name = "Soldiers Buckler";
      unityId = "2247105907";
      metadata = [3, 2, 14, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 76;
      name = "Soldiers Spear";
      unityId = "322747819";
      metadata = [3, 0, 6, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 77;
      name = "Spell of Healing";
      unityId = "2448034475";
      metadata = [3, 2, 22, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 78;
      name = "Splash";
      unityId = "3601711013";
      metadata = [3, 0, 8, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 79;
      name = "Steel Halberd";
      unityId = "1268234594";
      metadata = [3, 0, 23, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 80;
      name = "Sunlit Blade";
      unityId = "3253817716";
      metadata = [3, 0, 15, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 81;
      name = "Teardrop Staff";
      unityId = "3409749986";
      metadata = [3, 0, 12, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 82;
      name = "The ArchMages staff";
      unityId = "3607184235";
      metadata = [3, 0, 24, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 83;
      name = "The Chained Orb";
      unityId = "1629230594";
      metadata = [3, 2, 0, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 84;
      name = "The Champions Falchion";
      unityId = "1497491615";
      metadata = [3, 0, 20, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 85;
      name = "The Dreambinder's Blades";
      unityId = "2958353128";
      metadata = [3, 0, 19, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 86;
      name = "The Manawell Pendant";
      unityId = "1166711137";
      metadata = [3, 2, 1, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 87;
      name = "Thunder Charge";
      unityId = "806237574";
      metadata = [3, 2, 23, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 88;
      name = "Very Shiny Boots";
      unityId = "1511011266";
      metadata = [3, 1, 15, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 89;
      name = "Waterknot";
      unityId = "3421549664";
      metadata = [3, 0, 11, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 90;
      name = "Wooden Sword";
      unityId = "2069047119";
      metadata = [3, 0, 25, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 91;
      name = "Woodland Staff";
      unityId = "2564641913";
      metadata = [3, 0, 13, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
    {
      id = 92;
      name = "Yam";
      unityId = "3366400426";
      metadata = [3, 2, 24, 0];
      ableClasses = [0, 1, 2];
      tier = 1;
    },
  ];

  public let monsters : [Monster] = [
    {
      id = 0;
      name = "Crypee";
      gold = 5;
      xp = 90;
      itemReward = #SpecificItem({ items = [62] });
      itemProb = 100;
    },
    {
      id = 1;
      name = "Dark Beoite";
      gold = 2;
      xp = 35;
      itemReward = #SpecificItem({ items = [35] });
      itemProb = 100;
    },
    {
      id = 2;
      name = "Armed Grunkus";
      gold = 4;
      xp = 75;
      itemReward = #SpecificItem({ items = [92] });
      itemProb = 10;
    },
    {
      id = 3;
      name = "Beoite";
      gold = 1;
      xp = 20;
      itemReward = #SpecificItem({ items = [32] });
      itemProb = 10;
    },
    {
      id = 4;
      name = "Burrowing Spider Tree";
      gold = 3;
      xp = 40;
      itemReward = #SpecificItem({ items = [27] });
      itemProb = 10;
    },
    {
      id = 5;
      name = "Cruranid";
      gold = 1;
      xp = 23;
      itemReward = #SpecificItem({ items = [27] });
      itemProb = 10;
    },
    {
      id = 6;
      name = "Dark Cruranid";
      gold = 2;
      xp = 38;
      itemReward = #SpecificItem({ items = [32] });
      itemProb = 10;
    },
    {
      id = 7;
      name = "Dark Grunkus";
      gold = 2;
      xp = 45;
      itemReward = #SpecificItem({ items = [32] });
      itemProb = 10;
    },
    {
      id = 8;
      name = "Den Rat";
      gold = 1;
      xp = 30;
      itemReward = #SpecificItem({ items = [32] });
      itemProb = 10;
    },
    {
      id = 9;
      name = "The Scolopendrea";
      gold = 20;
      xp = 200;
      itemReward = #SpecificItem({ items = [32] });
      itemProb = 10;
    },
    {
      id = 10;
      name = "Grunk";
      gold = 1;
      xp = 18;
      itemReward = #SpecificItem({ items = [92] });
      itemProb = 10;
    },
    {
      id = 11;
      name = "Grunkus";
      gold = 2;
      xp = 33;
      itemReward = #SpecificItem({ items = [92] });
      itemProb = 10;
    },
    {
      id = 12;
      name = "Mud Slurghog";
      gold = 3;
      xp = 40;
      itemReward = #SpecificItem({ items = [92] });
      itemProb = 10;
    },
    {
      id = 13;
      name = "Slurghog";
      gold = 2;
      xp = 35;
      itemReward = #SpecificItem({ items = [92] });
      itemProb = 10;
    },
    {
      id = 14;
      name = "Scolodra";
      gold = 4;
      xp = 60;
      itemReward = #SpecificItem({ items = [27] });
      itemProb = 10;
    },
    {
      id = 15;
      name = "Cruranidius";
      gold = 15;
      xp = 150;
      itemReward = #SpecificItem({ items = [27] });
      itemProb = 10;
    },
    {
      id = 16;
      name = "Tired Den Rat";
      gold = 1;
      xp = 22;
      itemReward = #SpecificItem({ items = [27] });
      itemProb = 10;
    },
  ];

  public let chests : [TreasureChest] = [
    // placed
    {
      id = 0;
      name = "2 full mana potions";
      gold = 0;
      itemReward = #SpecificItem({ items = [30, 30] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 1;
      name = "Fire Katana";
      gold = 0;
      itemReward = #SpecificItem({ items = [39] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 2;
      name = "Gold by Corn 25";
      gold = 25;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 3;
      name = "Gold by Corn 10";
      gold = 10;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 4;
      name = "5 full red potions";
      gold = 0;
      itemReward = #SpecificItem({ items = [68, 68, 68, 68, 68] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 5;
      name = "Tier 2 Overworld 1";
      gold = 0;
      itemReward = #RandomItem({ tier = 2 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 6;
      name = "Tier 2 Overworld 2";
      gold = 0;
      itemReward = #RandomItem({ tier = 2 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 7;
      name = "Tier 2 Overworld 3";
      gold = 0;
      itemReward = #RandomItem({ tier = 2 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 8;
      name = "Tier 2 Overworld 4";
      gold = 0;
      itemReward = #RandomItem({ tier = 2 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 9;
      name = "Tier 2 Overworld 5";
      gold = 0;
      itemReward = #RandomItem({ tier = 2 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 10;
      name = "Splash";
      gold = 0;
      itemReward = #SpecificItem({ items = [78] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 11;
      name = "Tier 2 City Corner";
      gold = 0;
      itemReward = #RandomItem({ tier = 2 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 12;
      name = "Tier 3 Platform Over Water";
      gold = 0;
      itemReward = #RandomItem({ tier = 3 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 13;
      name = "Gold by Lake 10";
      gold = 10;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    //placed
    {
      id = 14;
      name = "Tier 3 in Skull Trees";
      gold = 0;
      itemReward = #RandomItem({ tier = 3 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 15;
      name = "Amethyst Pendant";
      gold = 0;
      itemReward = #SpecificItem { items = ([26]) };
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 16;
      name = "Tier 3 in Dead Trees";
      gold = 0;
      itemReward = #RandomItem({ tier = 3 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 17;
      name = "Gold Below Obelisk Platform 15";
      gold = 15;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 18;
      name = "2 yams";
      gold = 0;
      itemReward = #SpecificItem({ items = [92, 92] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 19;
      name = "Bread";
      gold = 0;
      itemReward = #SpecificItem({ items = [32] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 20;
      name = "Tier 3 in Elf Ruins";
      gold = 0;
      itemReward = #RandomItem({ tier = 3 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 21;
      name = "Fireblast";
      gold = 0;
      itemReward = #SpecificItem({ items = [40] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 22;
      name = "3 apples in grain storage 1";
      gold = 0;
      itemReward = #SpecificItem({ items = [27, 27, 27] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 23;
      name = "Tier 1 grain storage 1";
      gold = 0;
      itemReward = #RandomItem({ tier = 1 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 24;
      name = "Bread grain storage 2";
      gold = 0;
      itemReward = #SpecificItem({ items = [32] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 25;
      name = "Gold grain storage 2 5";
      gold = 5;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 26;
      name = "Leather Helmet Guardhouse";
      gold = 0;
      itemReward = #SpecificItem({ items = [52] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 27;
      name = "Leather Boots Guardhouse2";
      gold = 0;
      itemReward = #SpecificItem({ items = [51] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 28;
      name = "Gold house porch 3 5";
      gold = 5;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 29;
      name = "Gold house wood 5";
      gold = 5;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 30;
      name = "Tier 1 non gran gran";
      gold = 0;
      itemReward = #RandomItem({ tier = 1 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 31;
      name = "Healing Potion Shop";
      gold = 0;
      itemReward = #SpecificItem({ items = [77] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 32;
      name = "Cauldron Lid Tavern upstairs";
      gold = 0;
      itemReward = #SpecificItem({ items = [77] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 33;
      name = "Gold Tavern upstairs 20";
      gold = 20;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 34;
      name = "Melantyls Armor Town hall";
      gold = 0;
      itemReward = #SpecificItem({ items = [54] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 35;
      name = "Gold+ 2story upstairs 2 20";
      gold = 20;
      itemReward = #SpecificItem({ items = [35] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 37;
      name = "Fire Wand dead forest cave";
      gold = 0;
      itemReward = #SpecificItem({ items = [17] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 38;
      name = "4 red potions dead forest cave";
      gold = 0;
      itemReward = #SpecificItem({ items = [68, 68, 68, 68, 68] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 39;
      name = "gold dead forest cave 15";
      gold = 15;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 40;
      name = "5 half potions hiddenpath cave";
      gold = 0;
      itemReward = #SpecificItem({ items = [47, 47, 47, 47, 47] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 41;
      name = "rune of doom pond cave";
      gold = 0;
      itemReward = #SpecificItem({ items = [70] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 42;
      name = "2 full potions pond cave";
      gold = 0;
      itemReward = #SpecificItem({ items = [68, 68] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 43;
      name = "gold pond cave 35";
      gold = 35;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 44;
      name = "Tier 2 v. graveyard cave";
      gold = 0;
      itemReward = #RandomItem({ tier = 2 });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 45;
      name = "light shard v. graveyard cave";
      gold = 0;
      itemReward = #SpecificItem({ items = [71] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 46;
      name = "Blades from Tiana";
      gold = 0;
      itemReward = #SpecificItem({ items = [36] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 47;
      name = "Bow from Archer";
      gold = 0;
      itemReward = #SpecificItem({ items = [31] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 48;
      name = "Pendant from Herl";
      gold = 0;
      itemReward = #SpecificItem({ items = [63] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 49;
      name = "Grandma Start Gift";
      gold = 0;
      itemReward = #SpecificItem({ items = [68, 68, 68, 68, 68, 38] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 50;
      name = "Gold from Eldre";
      gold = 50;
      itemReward = #None;
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
    // placed
    {
      id = 51;
      name = "Monster Jaw";
      gold = 0;
      itemReward = #SpecificItem({ items = [57] });
      prerequisites = [];
      position = ?{ x = 1.0; y = 1.0 };
    },
  ];

  public let events : [PlotEvent] = [];
};
