/// @description Skill Tree - Meta Progression System
/// Players unlock nodes permanently, then select 5 active mods before each run
/// @description Skill Tree - Meta Progression System (IMPROVED LAYOUT)
/// Reorganized for cleaner connections and expanded content

global.SkillTree = {
    
    // ==========================================
    // ROOT - CENTER (400, 300)
    // ==========================================
    root: {
        id: "root",
        type: "character_unlock",
        name: "Warrior",
        description: "The first barbarian. Fury incarnate.",
        character: CharacterClass.WARRIOR,
        cost: 0,
        unlocked: true,
        position: {x: 400, y: 300},
        connections: ["warrior_path", "universal_path", "arsenal_path", "combat_path"],
        sprite: spr_vh_walk_south
    },
    
    // ==========================================
    // NORTH-WEST: WARRIOR BRANCH (Aggressive melee)
    // ==========================================
    
    warrior_path: {
        id: "warrior_path",
        type: "branch",
        name: "Path of Fury",
        description: "Warrior-specific enhancements",
        cost: 0,
        unlocked: false,
        position: {x: 250, y: 200},
        connections: ["root", "warrior_rage_1", "warrior_armor_1", "warrior_lifesteal"],
        sprite: spr_mod_default
    },
    
    warrior_rage_1: {
        id: "warrior_rage_1",
        type: "mod_unlock",
        name: "Berserker Rage",
        description: "Warrior: Rage builds 50% faster",
        mod_key: "BerserkerRage",
        required_character: CharacterClass.WARRIOR,
        cost: 200,
        unlocked: false,
        position: {x: 180, y: 150},
        connections: ["warrior_path", "warrior_rage_2"],
        sprite: spr_mod_default
    },
    
    warrior_rage_2: {
        id: "warrior_rage_2",
        type: "mod_unlock",
        name: "Endless Fury",
        description: "Warrior: Rage doesn't decay",
        mod_key: "EndlessFury",
        required_character: CharacterClass.WARRIOR,
        cost: 400,
        unlocked: false,
        position: {x: 120, y: 120},
        connections: ["warrior_rage_1", "warrior_rage_3"],
        sprite: spr_mod_default
    },
    
    warrior_rage_3: {
        id: "warrior_rage_3",
        type: "mod_unlock",
        name: "Primal Scream",
        description: "Warrior: At max rage, roar to fear nearby enemies",
        mod_key: "PrimalScream",
        required_character: CharacterClass.WARRIOR,
        cost: 600,
        unlocked: false,
        position: {x: 80, y: 80},
        connections: ["warrior_rage_2"],
        sprite: spr_mod_default
    },
    
    warrior_armor_1: {
        id: "warrior_armor_1",
        type: "mod_unlock",
        name: "Iron Hide",
        description: "Warrior: +3 Armor",
        mod_key: "IronHide",
        required_character: CharacterClass.WARRIOR,
        cost: 250,
        unlocked: false,
        position: {x: 220, y: 120},
        connections: ["warrior_path", "warrior_armor_2"],
        sprite: spr_mod_default
    },
    
    warrior_armor_2: {
        id: "warrior_armor_2",
        type: "mod_unlock",
        name: "Unbreakable",
        description: "Warrior: Cannot be interrupted while attacking",
        mod_key: "Unbreakable",
        required_character: CharacterClass.WARRIOR,
        cost: 500,
        unlocked: false,
        position: {x: 180, y: 70},
        connections: ["warrior_armor_1", "warrior_armor_3"],
        sprite: spr_mod_default
    },
    
    warrior_armor_3: {
        id: "warrior_armor_3",
        type: "mod_unlock",
        name: "Retaliation",
        description: "Warrior: Reflect 25% of damage taken",
        mod_key: "Retaliation",
        required_character: CharacterClass.WARRIOR,
        cost: 700,
        unlocked: false,
        position: {x: 150, y: 30},
        connections: ["warrior_armor_2"],
        sprite: spr_mod_default
    },
    
    warrior_lifesteal: {
        id: "warrior_lifesteal",
        type: "mod_unlock",
        name: "Blood Drinker",
        description: "Warrior: 10% lifesteal on melee hits",
        mod_key: "BloodDrinker",
        required_character: CharacterClass.WARRIOR,
        cost: 300,
        unlocked: false,
        position: {x: 280, y: 140},
        connections: ["warrior_path", "warrior_execute"],
        sprite: spr_mod_default
    },
    
    warrior_execute: {
        id: "warrior_execute",
        type: "mod_unlock",
        name: "Execute",
        description: "Warrior: Kills below 20% HP restore 50 HP",
        mod_key: "Execute",
        required_character: CharacterClass.WARRIOR,
        cost: 450,
        unlocked: false,
        position: {x: 300, y: 90},
        connections: ["warrior_lifesteal"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // NORTH: ARSENAL BRANCH (Weapon unlocks)
    // ==========================================
    
    arsenal_path: {
        id: "arsenal_path",
        type: "branch",
        name: "Arsenal",
        description: "Unlock new weapons",
        cost: 0,
        unlocked: false,
        position: {x: 400, y: 180},
        connections: ["root", "dagger_unlock", "bat_unlock", "boomerang_unlock"],
        sprite: spr_mod_default
    },
    
    dagger_unlock: {
        id: "dagger_unlock",
        type: "weapon_unlock",
        name: "Unlock: Dagger",
        description: "Fast combo strikes with lunge finisher",
        weapon: Weapon.Dagger,
        cost: 250,
        unlocked: false,
        position: {x: 340, y: 130},
        connections: ["arsenal_path", "dagger_mod_1"],
        sprite: spr_dagger
    },
    
    dagger_mod_1: {
        id: "dagger_mod_1",
        type: "mod_unlock",
        name: "Assassin's Edge",
        description: "Dagger attacks from behind deal 2x damage",
        mod_key: "AssassinsEdge",
        cost: 400,
        unlocked: false,
        position: {x: 300, y: 80},
        connections: ["dagger_unlock", "dagger_mod_2"],
        sprite: spr_mod_default
    },
    
    dagger_mod_2: {
        id: "dagger_mod_2",
        type: "mod_unlock",
        name: "Shadow Step",
        description: "Dagger lunge goes 2x farther",
        mod_key: "ShadowStep",
        cost: 550,
        unlocked: false,
        position: {x: 270, y: 40},
        connections: ["dagger_mod_1"],
        sprite: spr_mod_default
    },
    
    bat_unlock: {
        id: "bat_unlock",
        type: "weapon_unlock",
        name: "Unlock: Baseball Bat",
        description: "Powerful swing with massive knockback",
        weapon: Weapon.BaseballBat,
        cost: 350,
        unlocked: false,
        position: {x: 400, y: 100},
        connections: ["arsenal_path", "bat_mod_1"],
        sprite: spr_way_better_bat
    },
    
    bat_mod_1: {
        id: "bat_mod_1",
        type: "mod_unlock",
        name: "Homerun King",
        description: "Bat hits launch enemies into others",
        mod_key: "HomerunKing",
        cost: 450,
        unlocked: false,
        position: {x: 400, y: 40},
        connections: ["bat_unlock", "bat_mod_2"],
        sprite: spr_mod_default
    },
    
    bat_mod_2: {
        id: "bat_mod_2",
        type: "mod_unlock",
        name: "Grand Slam",
        description: "3rd combo hit stuns enemies for 2 seconds",
        mod_key: "GrandSlam",
        cost: 600,
        unlocked: false,
        position: {x: 400, y: 0},
        connections: ["bat_mod_1"],
        sprite: spr_mod_default
    },
    
    boomerang_unlock: {
        id: "boomerang_unlock",
        type: "weapon_unlock",
        name: "Unlock: Boomerang",
        description: "Returning projectile that hits multiple times",
        weapon: Weapon.Boomerang,
        cost: 300,
        unlocked: false,
        position: {x: 460, y: 130},
        connections: ["arsenal_path", "boomerang_mod_1"],
        sprite: spr_boomerang
    },
    
    boomerang_mod_1: {
        id: "boomerang_mod_1",
        type: "mod_unlock",
        name: "Triple Throw",
        description: "Throw 3 boomerangs at once",
        mod_key: "TripleThrow",
        cost: 500,
        unlocked: false,
        position: {x: 500, y: 80},
        connections: ["boomerang_unlock", "boomerang_mod_2"],
        sprite: spr_mod_default
    },
    
    boomerang_mod_2: {
        id: "boomerang_mod_2",
        type: "mod_unlock",
        name: "Whirlwind",
        description: "Boomerangs orbit you before returning",
        mod_key: "Whirlwind",
        cost: 650,
        unlocked: false,
        position: {x: 530, y: 40},
        connections: ["boomerang_mod_1"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // NORTH-EAST: COMBAT BRANCH (Universal combat mods)
    // ==========================================
    
    combat_path: {
        id: "combat_path",
        type: "branch",
        name: "Combat Mastery",
        description: "Universal combat enhancements",
        cost: 0,
        unlocked: false,
        position: {x: 550, y: 200},
        connections: ["root", "multishot", "piercing", "critical_strike"],
        sprite: spr_mod_default
    },
    
    multishot: {
        id: "multishot",
        type: "mod_unlock",
        name: "Multishot",
        description: "+2 Projectiles on ranged attacks",
        mod_key: "Multishot",
        cost: 400,
        unlocked: false,
        position: {x: 620, y: 150},
        connections: ["combat_path", "multishot_2"],
        sprite: spr_mod_default
    },
    
    multishot_2: {
        id: "multishot_2",
        type: "mod_unlock",
        name: "Barrage",
        description: "+2 more projectiles (5 total)",
        mod_key: "Barrage",
        cost: 700,
        unlocked: false,
        position: {x: 670, y: 110},
        connections: ["multishot"],
        sprite: spr_mod_default
    },
    
    piercing: {
        id: "piercing",
        type: "mod_unlock",
        name: "Piercing Shot",
        description: "Projectiles pierce 2 enemies",
        mod_key: "PiercingShot",
        cost: 350,
        unlocked: false,
        position: {x: 600, y: 120},
        connections: ["combat_path", "piercing_2"],
        sprite: spr_mod_default
    },
    
    piercing_2: {
        id: "piercing_2",
        type: "mod_unlock",
        name: "Impaling Shot",
        description: "Pierce 5 enemies, pin last one",
        mod_key: "ImpalingShot",
        cost: 600,
        unlocked: false,
        position: {x: 640, y: 70},
        connections: ["piercing"],
        sprite: spr_mod_default
    },
    
    critical_strike: {
        id: "critical_strike",
        type: "mod_unlock",
        name: "Critical Strike",
        description: "15% chance for 2x damage",
        mod_key: "CriticalStrike",
        cost: 300,
        unlocked: false,
        position: {x: 580, y: 140},
        connections: ["combat_path", "critical_strike_2"],
        sprite: spr_mod_default
    },
    
    critical_strike_2: {
        id: "critical_strike_2",
        type: "mod_unlock",
        name: "Deadly Precision",
        description: "25% chance, 2.5x damage",
        mod_key: "DeadlyPrecision",
        cost: 600,
        unlocked: false,
        position: {x: 610, y: 90},
        connections: ["critical_strike", "critical_strike_3"],
        sprite: spr_mod_default
    },
    
    critical_strike_3: {
        id: "critical_strike_3",
        type: "mod_unlock",
        name: "Assassinate",
        description: "Crits have 10% chance to instantly kill",
        mod_key: "Assassinate",
        cost: 900,
        unlocked: false,
        position: {x: 640, y: 40},
        connections: ["critical_strike_2"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // EAST: UNIVERSAL STATS BRANCH
    // ==========================================
    
    universal_path: {
        id: "universal_path",
        type: "branch",
        name: "Universal Skills",
        description: "Stats usable by all characters",
        cost: 0,
        unlocked: false,
        position: {x: 550, y: 300},
        connections: ["root", "stat_hp_1", "stat_attack_1", "stat_speed_1"],
        sprite: spr_mod_default
    },
    
    stat_hp_1: {
        id: "stat_hp_1",
        type: "mod_unlock",
        name: "Vitality I",
        description: "+20 Max HP",
        mod_key: "Vitality1",
        cost: 150,
        unlocked: false,
        position: {x: 620, y: 280},
        connections: ["universal_path", "stat_hp_2"],
        sprite: spr_mod_default
    },
    
    stat_hp_2: {
        id: "stat_hp_2",
        type: "mod_unlock",
        name: "Vitality II",
        description: "+40 Max HP",
        mod_key: "Vitality2",
        cost: 300,
        unlocked: false,
        position: {x: 680, y: 270},
        connections: ["stat_hp_1", "stat_hp_3"],
        sprite: spr_mod_default
    },
    
    stat_hp_3: {
        id: "stat_hp_3",
        type: "mod_unlock",
        name: "Vitality III",
        description: "+60 Max HP",
        mod_key: "Vitality3",
        cost: 500,
        unlocked: false,
        position: {x: 730, y: 260},
        connections: ["stat_hp_2"],
        sprite: spr_mod_default
    },
    
    stat_attack_1: {
        id: "stat_attack_1",
        type: "mod_unlock",
        name: "Strength I",
        description: "+15% Attack Damage",
        mod_key: "Strength1",
        cost: 200,
        unlocked: false,
        position: {x: 620, y: 320},
        connections: ["universal_path", "stat_attack_2"],
        sprite: spr_mod_default
    },
    
    stat_attack_2: {
        id: "stat_attack_2",
        type: "mod_unlock",
        name: "Strength II",
        description: "+30% Attack Damage",
        mod_key: "Strength2",
        cost: 400,
        unlocked: false,
        position: {x: 680, y: 330},
        connections: ["stat_attack_1", "stat_attack_3"],
        sprite: spr_mod_default
    },
    
    stat_attack_3: {
        id: "stat_attack_3",
        type: "mod_unlock",
        name: "Strength III",
        description: "+50% Attack Damage",
        mod_key: "Strength3",
        cost: 650,
        unlocked: false,
        position: {x: 730, y: 340},
        connections: ["stat_attack_2"],
        sprite: spr_mod_default
    },
    
    stat_speed_1: {
        id: "stat_speed_1",
        type: "mod_unlock",
        name: "Swiftness I",
        description: "+15% Movement Speed",
        mod_key: "Swiftness1",
        cost: 180,
        unlocked: false,
        position: {x: 600, y: 350},
        connections: ["universal_path", "stat_speed_2"],
        sprite: spr_mod_default
    },
    
    stat_speed_2: {
        id: "stat_speed_2",
        type: "mod_unlock",
        name: "Swiftness II",
        description: "+30% Movement Speed",
        mod_key: "Swiftness2",
        cost: 350,
        unlocked: false,
        position: {x: 650, y: 370},
        connections: ["stat_speed_1", "stat_speed_3"],
        sprite: spr_mod_default
    },
    
    stat_speed_3: {
        id: "stat_speed_3",
        type: "mod_unlock",
        name: "Swiftness III",
        description: "+50% Movement Speed",
        mod_key: "Swiftness3",
        cost: 550,
        unlocked: false,
        position: {x: 700, y: 390},
        connections: ["stat_speed_2"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // SOUTH-EAST: HOLY MAGE CHARACTER
    // ==========================================
    
    holy_mage_unlock: {
        id: "holy_mage_unlock",
        type: "character_unlock",
        name: "Unlock: Holy Mage",
        description: "Master of projectiles and area control",
        character: CharacterClass.HOLY_MAGE,
        cost: 800,
        unlocked: false,
        position: {x: 550, y: 400},
        connections: ["universal_path", "mage_path"],
        sprite: spr_vh_walk_south
    },
    
    mage_path: {
        id: "mage_path",
        type: "branch",
        name: "Path of Divinity",
        description: "Holy Mage enhancements",
        cost: 0,
        unlocked: false,
        position: {x: 600, y: 450},
        connections: ["holy_mage_unlock", "mage_mana_1", "mage_blessed_1", "mage_projectile"],
        sprite: spr_mod_default
    },
    
    mage_mana_1: {
        id: "mage_mana_1",
        type: "mod_unlock",
        name: "Mana Overflow",
        description: "Mage: +50 Max Mana, +50% regen",
        mod_key: "ManaOverflow",
        required_character: CharacterClass.HOLY_MAGE,
        cost: 250,
        unlocked: false,
        position: {x: 650, y: 480},
        connections: ["mage_path", "mage_mana_2"],
        sprite: spr_mod_default
    },
    
    mage_mana_2: {
        id: "mage_mana_2",
        type: "mod_unlock",
        name: "Arcane Battery",
        description: "Mage: Mana regens even while casting",
        mod_key: "ArcaneBattery",
        required_character: CharacterClass.HOLY_MAGE,
        cost: 450,
        unlocked: false,
        position: {x: 680, y: 520},
        connections: ["mage_mana_1"],
        sprite: spr_mod_default
    },
    
    mage_blessed_1: {
        id: "mage_blessed_1",
        type: "mod_unlock",
        name: "Sanctified Ground",
        description: "Mage: Blessed ground radius +50%",
        mod_key: "SanctifiedGround",
        required_character: CharacterClass.HOLY_MAGE,
        cost: 300,
        unlocked: false,
        position: {x: 620, y: 500},
        connections: ["mage_path", "mage_blessed_2"],
        sprite: spr_mod_default
    },
    
    mage_blessed_2: {
        id: "mage_blessed_2",
        type: "mod_unlock",
        name: "Divine Wrath",
        description: "Mage: Blessed ground damages enemies",
        mod_key: "DivineWrath",
        required_character: CharacterClass.HOLY_MAGE,
        cost: 500,
        unlocked: false,
        position: {x: 640, y: 550},
        connections: ["mage_blessed_1", "mage_blessed_3"],
        sprite: spr_mod_default
    },
    
    mage_blessed_3: {
        id: "mage_blessed_3",
        type: "mod_unlock",
        name: "Sanctuary",
        description: "Mage: Blessed ground makes you invincible",
        mod_key: "Sanctuary",
        required_character: CharacterClass.HOLY_MAGE,
        cost: 800,
        unlocked: false,
        position: {x: 660, y: 590},
        connections: ["mage_blessed_2"],
        sprite: spr_mod_default
    },
    
    mage_projectile: {
        id: "mage_projectile",
        type: "mod_unlock",
        name: "Zealot's Fervor",
        description: "Mage: Projectiles gain homing",
        mod_key: "ZealotsFervor",
        required_character: CharacterClass.HOLY_MAGE,
        cost: 400,
        unlocked: false,
        position: {x: 560, y: 480},
        connections: ["mage_path", "mage_projectile_2"],
        sprite: spr_mod_default
    },
    
    mage_projectile_2: {
        id: "mage_projectile_2",
        type: "mod_unlock",
        name: "Holy Nova",
        description: "Mage: Projectiles explode on hit",
        mod_key: "HolyNova",
        required_character: CharacterClass.HOLY_MAGE,
        cost: 600,
        unlocked: false,
        position: {x: 520, y: 520},
        connections: ["mage_projectile"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // SOUTH-WEST: VAMPIRE CHARACTER
    // ==========================================
    
    vampire_unlock: {
        id: "vampire_unlock",
        type: "character_unlock",
        name: "Unlock: Vampire",
        description: "High mobility with lifesteal mechanics",
        character: CharacterClass.VAMPIRE,
        cost: 1000,
        unlocked: false,
        position: {x: 250, y: 400},
        connections: ["universal_path", "vampire_path"],
        sprite: spr_vh_walk_south
    },
    
    vampire_path: {
        id: "vampire_path",
        type: "branch",
        name: "Path of Blood",
        description: "Vampire enhancements",
        cost: 0,
        unlocked: false,
        position: {x: 200, y: 450},
        connections: ["vampire_unlock", "vampire_lifesteal_1", "vampire_frenzy_1", "vampire_dash"],
        sprite: spr_mod_default
    },
    
    vampire_lifesteal_1: {
        id: "vampire_lifesteal_1",
        type: "mod_unlock",
        name: "Thirst",
        description: "Vampire: +10% lifesteal",
        mod_key: "Thirst",
        required_character: CharacterClass.VAMPIRE,
        cost: 300,
        unlocked: false,
        position: {x: 150, y: 480},
        connections: ["vampire_path", "vampire_lifesteal_2"],
        sprite: spr_mod_default
    },
    
    vampire_lifesteal_2: {
        id: "vampire_lifesteal_2",
        type: "mod_unlock",
        name: "Bloodlust",
        description: "Vampire: Lifesteal grants temporary damage",
        mod_key: "Bloodlust",
        required_character: CharacterClass.VAMPIRE,
        cost: 500,
        unlocked: false,
        position: {x: 120, y: 520},
        connections: ["vampire_lifesteal_1", "vampire_lifesteal_3"],
        sprite: spr_mod_default
    },
    
    vampire_lifesteal_3: {
        id: "vampire_lifesteal_3",
        type: "mod_unlock",
        name: "Crimson Pact",
        description: "Vampire: Lifesteal heals double, but max HP -20%",
        mod_key: "CrimsonPact",
        required_character: CharacterClass.VAMPIRE,
        cost: 700,
        unlocked: false,
        position: {x: 100, y: 560},
        connections: ["vampire_lifesteal_2"],
        sprite: spr_mod_default
    },
    
    vampire_frenzy_1: {
        id: "vampire_frenzy_1",
        type: "mod_unlock",
        name: "Extended Frenzy",
        description: "Vampire: Blood frenzy lasts 2x longer",
        mod_key: "ExtendedFrenzy",
        required_character: CharacterClass.VAMPIRE,
        cost: 350,
        unlocked: false,
        position: {x: 220, y: 500},
        connections: ["vampire_path", "vampire_frenzy_2"],
        sprite: spr_mod_default
    },
    
    vampire_frenzy_2: {
        id: "vampire_frenzy_2",
        type: "mod_unlock",
        name: "Bloodrage",
        description: "Vampire: Frenzy grants immunity to CC",
        mod_key: "Bloodrage",
        required_character: CharacterClass.VAMPIRE,
        cost: 550,
        unlocked: false,
        position: {x: 240, y: 550},
        connections: ["vampire_frenzy_1"],
        sprite: spr_mod_default
    },
    
    vampire_dash: {
        id: "vampire_dash",
        type: "mod_unlock",
        name: "Bat Form",
        description: "Vampire: Dash cooldown -30%",
        mod_key: "BatForm",
        required_character: CharacterClass.VAMPIRE,
        cost: 400,
        unlocked: false,
        position: {x: 180, y: 520},
        connections: ["vampire_path", "vampire_dash_2"],
        sprite: spr_mod_default
    },
    
    vampire_dash_2: {
        id: "vampire_dash_2",
        type: "mod_unlock",
        name: "Mist Walker",
        description: "Vampire: Dash through enemies, dealing damage",
        mod_key: "MistWalker",
        required_character: CharacterClass.VAMPIRE,
        cost: 650,
        unlocked: false,
        position: {x: 160, y: 570},
        connections: ["vampire_dash"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // SOUTH: ELEMENTAL BRANCH
    // ==========================================
    
    elemental_path: {
        id: "elemental_path",
        type: "branch",
        name: "Elemental Arts",
        description: "Fire, Ice, Lightning enchantments",
        cost: 0,
        unlocked: false,
        position: {x: 400, y: 420},
        connections: ["root", "fire_enchant", "ice_enchant", "lightning_enchant"],
        sprite: spr_mod_default
    },
    
    fire_enchant: {
        id: "fire_enchant",
        type: "mod_unlock",
        name: "Fire Enchantment",
        description: "Attacks burn enemies over time",
        mod_key: "FireEnchantment",
        cost: 300,
        unlocked: false,
        position: {x: 340, y: 470},
        connections: ["elemental_path", "fire_enchant_2"],
        sprite: spr_mod_default
    },
    
    fire_enchant_2: {
        id: "fire_enchant_2",
        type: "mod_unlock",
        name: "Inferno",
        description: "Burn spreads to nearby enemies",
        mod_key: "Inferno",
        cost: 500,
        unlocked: false,
        position: {x: 310, y: 520},
        connections: ["fire_enchant", "fire_enchant_3"],
        sprite: spr_mod_default
    },
    
    fire_enchant_3: {
        id: "fire_enchant_3",
        type: "mod_unlock",
        name: "Pyroclasm",
        description: "Burning enemies explode on death",
        mod_key: "Pyroclasm",
        cost: 750,
        unlocked: false,
        position: {x: 290, y: 570},
        connections: ["fire_enchant_2"],
        sprite: spr_mod_default
    },
    
    ice_enchant: {
        id: "ice_enchant",
        type: "mod_unlock",
        name: "Ice Enchantment",
        description: "Attacks slow enemies by 50%",
        mod_key: "IceEnchantment",
        cost: 300,
        unlocked: false,
        position: {x: 400, y: 490},
        connections: ["elemental_path", "ice_enchant_2"],
        sprite: spr_mod_default
    },
    
    ice_enchant_2: {
        id: "ice_enchant_2",
        type: "mod_unlock",
        name: "Deep Freeze",
        description: "Slowed enemies can be frozen solid",
        mod_key: "DeepFreeze",
        cost: 500,
        unlocked: false,
        position: {x: 400, y: 550},
        connections: ["ice_enchant", "ice_enchant_3"],
        sprite: spr_mod_default
    },
    
    ice_enchant_3: {
        id: "ice_enchant_3",
        type: "mod_unlock",
        name: "Shatter",
        description: "Frozen enemies explode when hit",
        mod_key: "Shatter",
        cost: 750,
        unlocked: false,
        position: {x: 400, y: 600},
        connections: ["ice_enchant_2"],
        sprite: spr_mod_default
    },
    
    lightning_enchant: {
        id: "lightning_enchant",
        type: "mod_unlock",
        name: "Lightning Enchantment",
        description: "Attacks shock enemies",
        mod_key: "LightningEnchantment",
        cost: 300,
        unlocked: false,
        position: {x: 460, y: 470},
        connections: ["elemental_path", "lightning_enchant_2"],
        sprite: spr_mod_default
    },
    
    lightning_enchant_2: {
        id: "lightning_enchant_2",
        type: "mod_unlock",
        name: "Chain Lightning",
        description: "Lightning chains to 4 nearby enemies",
        mod_key: "ChainLightning",
        cost: 500,
        unlocked: false,
        position: {x: 490, y: 520},
        connections: ["lightning_enchant", "lightning_enchant_3"],
        sprite: spr_mod_default
    },
    
    lightning_enchant_3: {
        id: "lightning_enchant_3",
        type: "mod_unlock",
        name: "Storm Caller",
        description: "Chance to summon lightning strikes",
        mod_key: "StormCaller",
        cost: 750,
        unlocked: false,
        position: {x: 510, y: 570},
        connections: ["lightning_enchant_2"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // WEST: DEFENSIVE / UTILITY BRANCH
    // ==========================================
    
    defensive_path: {
        id: "defensive_path",
        type: "branch",
        name: "Survival",
        description: "Defensive and utility options",
        cost: 0,
        unlocked: false,
        position: {x: 250, y: 300},
        connections: ["root", "regen_1", "dodge_1", "shield_1"],
        sprite: spr_mod_default
    },
    
    regen_1: {
        id: "regen_1",
        type: "mod_unlock",
        name: "Regeneration",
        description: "Heal 1 HP every 3 seconds",
        mod_key: "Regeneration",
        cost: 200,
        unlocked: false,
        position: {x: 180, y: 280},
        connections: ["defensive_path", "regen_2"],
        sprite: spr_mod_default
    },
    
    regen_2: {
        id: "regen_2",
        type: "mod_unlock",
        name: "Fast Healing",
        description: "Heal 2 HP every 2 seconds",
        mod_key: "FastHealing",
        cost: 400,
        unlocked: false,
        position: {x: 130, y: 260},
        connections: ["regen_1", "regen_3"],
        sprite: spr_mod_default
    },
    
    regen_3: {
        id: "regen_3",
        type: "mod_unlock",
        name: "Troll Blood",
        description: "Heal 5 HP every second",
        mod_key: "TrollBlood",
        cost: 700,
        unlocked: false,
        position: {x: 90, y: 240},
        connections: ["regen_2"],
        sprite: spr_mod_default
    },
    
    dodge_1: {
        id: "dodge_1",
        type: "mod_unlock",
        name: "Evasion",
        description: "10% chance to dodge attacks",
        mod_key: "Evasion",
        cost: 250,
        unlocked: false,
        position: {x: 200, y: 320},
        connections: ["defensive_path", "dodge_2"],
        sprite: spr_mod_default
    },
    
    dodge_2: {
        id: "dodge_2",
        type: "mod_unlock",
        name: "Acrobat",
        description: "20% dodge chance",
        mod_key: "Acrobat",
        cost: 500,
        unlocked: false,
        position: {x: 150, y: 350},
        connections: ["dodge_1"],
        sprite: spr_mod_default
    },
    
    shield_1: {
        id: "shield_1",
        type: "mod_unlock",
        name: "Barrier",
        description: "Absorb 50 damage before taking HP damage",
        mod_key: "Barrier",
        cost: 300,
        unlocked: false,
        position: {x: 180, y: 350},
        connections: ["defensive_path", "shield_2"],
        sprite: spr_mod_default
    },
    
    shield_2: {
        id: "shield_2",
        type: "mod_unlock",
        name: "Fortified",
        description: "Shield regenerates over time",
        mod_key: "Fortified",
        cost: 550,
        unlocked: false,
        position: {x: 130, y: 380},
        connections: ["shield_1"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // SPECIAL: CHAIN/PROC EFFECTS
    // ==========================================
    
    chain_path: {
        id: "chain_path",
        type: "branch",
        name: "Chain Effects",
        description: "Powerful proc-based abilities",
        cost: 0,
        unlocked: false,
        position: {x: 300, y: 360},
        connections: ["root", "corpse_explosion", "lifesteal_universal"],
        sprite: spr_mod_default
    },
    
    corpse_explosion: {
        id: "corpse_explosion",
        type: "mod_unlock",
        name: "Corpse Explosion",
        description: "25% chance enemies explode on death",
        mod_key: "CorpseExplosion",
        cost: 450,
        unlocked: false,
        position: {x: 280, y: 410},
        connections: ["chain_path", "corpse_explosion_2"],
        sprite: spr_mod_default
    },
    
    corpse_explosion_2: {
        id: "corpse_explosion_2",
        type: "mod_unlock",
        name: "Chain Reaction",
        description: "Explosions can trigger more explosions",
        mod_key: "ChainReaction",
        cost: 700,
        unlocked: false,
        position: {x: 260, y: 460},
        connections: ["corpse_explosion"],
        sprite: spr_mod_default
    },
    
    lifesteal_universal: {
        id: "lifesteal_universal",
        type: "mod_unlock",
        name: "Life Drain",
        description: "5% lifesteal on all attacks",
        mod_key: "LifeDrain",
        cost: 350,
        unlocked: false,
        position: {x: 320, y: 410},
        connections: ["chain_path"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // LEVEL UNLOCKS
    // ==========================================
    
    arena_2_unlock: {
        id: "arena_2_unlock",
        type: "level_unlock",
        name: "Unlock: Cursed Catacombs",
        description: "Harder enemies, better soul rewards",
        level_id: "arena_2",
        cost: 1500,
        unlocked: false,
        position: {x: 500, y: 360},
        connections: ["root", "arena_3_unlock"],
        sprite: spr_mod_default
    },
    
    arena_3_unlock: {
        id: "arena_3_unlock",
        type: "level_unlock",
        name: "Unlock: Hellgate Fortress",
        description: "Elite challenge with massive rewards",
        level_id: "arena_3",
        cost: 3000,
        unlocked: false,
        position: {x: 500, y: 420},
        connections: ["arena_2_unlock"],
        sprite: spr_mod_default
    }
};

// In your player's stat recalculation (obj_player Step or wherever you calculate stats)
function ApplySkillTreeBonuses() {
    var bonus_hp = 0;
    var bonus_attack = 0;
    var bonus_speed = 0;
    
    // Check all stat boost nodes
    var node_keys = variable_struct_get_names(global.SkillTree);
    for (var i = 0; i < array_length(node_keys); i++) {
        var key = node_keys[i];
        var node = global.SkillTree[$ key];
        
        if (node.type == "stat_boost" && node.unlocked) {
            var stacks = node.current_stacks ?? 1;
            var total_bonus = node.bonus * stacks;
            
            switch (node.stat) {
                case "hp":
                    bonus_hp += total_bonus;
                    break;
                case "attack":
                    bonus_attack += total_bonus;
                    break;
                case "speed":
                    bonus_speed += total_bonus;
                    break;
            }
        }
    }
    
    // Apply bonuses (additive or multiplicative depending on design)
    maxHp += bonus_hp;
    attack *= (1 + bonus_attack);
    mySpeed *= (1 + bonus_speed);
}

//// Add particle effects when unlocking
//function SpawnUnlockParticles(_x, _y) {
//    part_particles_create(global.particle_system, _x, _y, global.pt_spark, 20);
//}

//// Add sound effects
//function PlayUnlockSound() {
//    audio_play_sound(snd_skill_unlock, 1, false);
//}

/// @file scr_SkillTreeSystem
/// @description Interactive web-like skill tree with pan/zoom navigation

function SkillTreeSystem() constructor {
    
    // ==========================================
    // CAMERA/VIEWPORT
    // ==========================================
    camera_x = 400;
    camera_y = 300;
    camera_target_x = 400;
    camera_target_y = 300;
    camera_zoom = 1.0;
    camera_target_zoom = 1.0;
    camera_min_zoom = 0.5;
    camera_max_zoom = 2.0;
    camera_smooth_speed = 0.15;
    
    pan_min_x = -200;
    pan_max_x = 1000;
    pan_min_y = -200;
    pan_max_y = 800;
    
    // ==========================================
    // SELECTION & INTERACTION
    // ==========================================
    selected_node_id = "root";
    hovered_node_id = noone;
    
    is_dragging = false;
    drag_start_x = 0;
    drag_start_y = 0;
    drag_camera_start_x = 0;
    drag_camera_start_y = 0;
    
    navigation_cooldown = 0;
    navigation_cooldown_max = 8;
    
    // ==========================================
    // VISUAL SETTINGS
    // ==========================================
    node_radius = 16;
    node_selected_radius = 50;
    node_hover_pulse = 0;
    
    connection_thickness = 2;
    connection_unlocked_color = c_yellow;
    connection_locked_color = c_dkgray;
    
    color_unlocked = c_lime;
    color_locked = c_gray;
    color_locked_available = c_white;
    color_locked_unavailable = c_red;
    color_selected = c_yellow;
    color_hover = c_aqua;
    
    pulse_speed = 0.05;
    unlock_animation_duration = 30;
    active_unlock_animations = [];
    
    show_info_panel = true;
    info_panel_alpha = 0;
    info_panel_target_alpha = 1;
    
    // ==========================================
    // UPDATE METHOD
    // ==========================================
    
    /// @function Update(_input, _mx, _my, _player_souls)
    static Update = function(_input, _mx, _my, _player_souls) {
        
        node_hover_pulse += pulse_speed;
        
        UpdateUnlockAnimations();
        
        info_panel_alpha = lerp(info_panel_alpha, info_panel_target_alpha, 0.1);
        
        if (navigation_cooldown > 0) navigation_cooldown--;
        
        HandleMouseInteraction(_input, _mx, _my);
        HandleKeyboardNavigation(_input);
        HandleZoom(_input);
        
        camera_x = lerp(camera_x, camera_target_x, camera_smooth_speed);
        camera_y = lerp(camera_y, camera_target_y, camera_smooth_speed);
        camera_zoom = lerp(camera_zoom, camera_target_zoom, camera_smooth_speed * 0.5);
        
        if (_input.Action) {
            TryUnlockNode(selected_node_id, _player_souls);
        }
    }
    
    // ==========================================
    // MOUSE INTERACTION
    // ==========================================
    
    /// @function HandleMouseInteraction(_input, _mx, _my)
    static HandleMouseInteraction = function(_input, _mx, _my) {
        var gui_w = display_get_gui_width();
        var gui_h = display_get_gui_height();
        
        // Middle mouse or right mouse drag to pan
        if (mouse_check_button_pressed(mb_middle) || mouse_check_button_pressed(mb_right)) {
            is_dragging = true;
            drag_start_x = _mx;
            drag_start_y = _my;
            drag_camera_start_x = camera_target_x;
            drag_camera_start_y = camera_target_y;
        }
        
        if (mouse_check_button_released(mb_middle) || mouse_check_button_released(mb_right)) {
            is_dragging = false;
        }
        
        if (is_dragging) {
            var delta_x = (_mx - drag_start_x) / camera_zoom;
            var delta_y = (_my - drag_start_y) / camera_zoom;
            
            camera_target_x = clamp(drag_camera_start_x - delta_x, pan_min_x, pan_max_x);
            camera_target_y = clamp(drag_camera_start_y - delta_y, pan_min_y, pan_max_y);
            
            hovered_node_id = noone;
            return;
        }
        
        // Check node hover
        hovered_node_id = noone;
        var node_keys = variable_struct_get_names(global.SkillTree);
        
        for (var i = 0; i < array_length(node_keys); i++) {
            var key = node_keys[i];
            var node = global.SkillTree[$ key];
            
            var screen_x = (node.position.x - camera_x) * camera_zoom + gui_w / 2;
            var screen_y = (node.position.y - camera_y) * camera_zoom + gui_h / 2;
            
            var check_radius = node_radius * camera_zoom;
            
            if (point_distance(_mx, _my, screen_x, screen_y) < check_radius) {
                hovered_node_id = key;
                
                if (_input.FirePress) {
                    selected_node_id = key;
                    CenterCameraOnNode(key);
                }
                break;
            }
        }
    }
    
    // ==========================================
    // KEYBOARD NAVIGATION
    // ==========================================
    
/// @function HandleKeyboardNavigation(_input)
static HandleKeyboardNavigation = function(_input) {
    if (navigation_cooldown > 0) return;
    
    var current_node = global.SkillTree[$ selected_node_id];
    if (!variable_struct_exists(current_node, "connections")) return;
    
    var moved = false;
    var best_node = noone;
    var best_score = -999999;
    
    // Find best node in direction
    if (_input.UpPress || _input.DownPress || _input.LeftPress || _input.RightPress) {
        
        var target_angle = 0;
        if (_input.UpPress) target_angle = 270;
        else if (_input.DownPress) target_angle = 90;
        else if (_input.LeftPress) target_angle = 180;
        else if (_input.RightPress) target_angle = 0;
        
        for (var i = 0; i < array_length(current_node.connections); i++) {
            var conn_id = current_node.connections[i];
            
            // SAFETY CHECK: Make sure connected node exists
            if (!variable_struct_exists(global.SkillTree, conn_id)) {
                continue;
            }
            
            var conn_node = global.SkillTree[$ conn_id];
            
            var angle = point_direction(
                current_node.position.x, current_node.position.y,
                conn_node.position.x, conn_node.position.y
            );
            
            var angle_diff = abs(angle_difference(angle, target_angle));
            var distance = point_distance(
                current_node.position.x, current_node.position.y,
                conn_node.position.x, conn_node.position.y
            );
            
            var _score = -angle_diff - (distance * 0.1);
            
            if (_score > best_score) {
                best_score = _score;
                best_node = conn_id;
                moved = true;
            }
        }
        
        if (moved && best_node != noone) {
            selected_node_id = best_node;
            CenterCameraOnNode(best_node);
            navigation_cooldown = navigation_cooldown_max;
        }
    }
}

    // ==========================================
    // ZOOM HANDLING
    // ==========================================
    
    /// @function HandleZoom(_input)
    static HandleZoom = function(_input) {
        // Mouse wheel zoom
        var wheel = mouse_wheel_up() - mouse_wheel_down();
        if (wheel != 0) {
            camera_target_zoom = clamp(camera_target_zoom + wheel * 0.1, camera_min_zoom, camera_max_zoom);
        }
        
        // Keyboard zoom (Q/E or PageUp/PageDown)
        if (keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(vk_pageup)) {
            camera_target_zoom = clamp(camera_target_zoom + 0.2, camera_min_zoom, camera_max_zoom);
        }
        if (keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_pagedown)) {
            camera_target_zoom = clamp(camera_target_zoom - 0.2, camera_min_zoom, camera_max_zoom);
        }
        
        // Reset zoom (R key)
        if (keyboard_check_pressed(ord("R"))) {
            camera_target_zoom = 1.0;
            CenterCameraOnNode(selected_node_id);
        }
    }
    
    // ==========================================
    // CAMERA HELPERS
    // ==========================================
    
    /// @function CenterCameraOnNode(_node_id)
    static CenterCameraOnNode = function(_node_id) {
        var node = global.SkillTree[$ _node_id];
        if (node == noone) return;
        
        camera_target_x = node.position.x;
        camera_target_y = node.position.y;
    }
    
    // ==========================================
    // UNLOCK LOGIC
    // ==========================================
    
/// @function TryUnlockNode(_node_id, _player_souls)
static TryUnlockNode = function(_node_id, _player_souls) {
    var node = global.SkillTree[$ _node_id];
    if (node == noone) return false;
    
    if (node.unlocked) {
        show_debug_message("Node already unlocked: " + node.name);
        return false;
    }
    
    if (!CanUnlockNode(_node_id)) {
        show_debug_message("Cannot unlock - path blocked: " + node.name);
        return false;
    }
    
    if (_player_souls < node.cost) {
        show_debug_message("Not enough souls! Need: " + string(node.cost) + ", Have: " + string(_player_souls));
        return false;
    }
    
    // Deduct cost
    SpendSouls(node.cost);
    
    // Unlock node
    node.unlocked = true;
    
    // Add to save data (using correct path)
    if (!array_contains(global.SaveData.career.skill_tree.unlocked_nodes, _node_id)) {
        array_push(global.SaveData.career.skill_tree.unlocked_nodes, _node_id);
    }
    
    // Apply unlock effects
    ApplyNodeEffects(_node_id, node);
    
    // Start unlock animation
    array_push(active_unlock_animations, {
        node_id: _node_id,
        timer: 0,
        duration: unlock_animation_duration
    });
    
    SaveGame();
    
    show_debug_message("Unlocked: " + node.name + " for " + string(node.cost) + " souls");
    return true;
}
    
    /// @function CanUnlockNode(_node_id)
static CanUnlockNode = function(_node_id) {
    var node = global.SkillTree[$ _node_id];
    if (node.unlocked) return false;
    
    // Root is always available
    if (_node_id == "root") return true;
    
    // Check if any connected nodes are unlocked
    if (!variable_struct_exists(node, "connections")) return false;
    
    for (var i = 0; i < array_length(node.connections); i++) {
        var conn_id = node.connections[i];
        
        // SAFETY CHECK: Make sure connected node exists
        if (!variable_struct_exists(global.SkillTree, conn_id)) {
            show_debug_message("WARNING: Node '" + _node_id + "' references non-existent connection: '" + conn_id + "'");
            continue;
        }
        
        var conn_node = global.SkillTree[$ conn_id];
        
        if (conn_node.unlocked) {
            return true;
        }
    }
    
    return false;
}
    
    /// @function ApplyNodeEffects(_node_id, _node)
    static ApplyNodeEffects = function(_node_id, _node) {
        switch (_node.type) {
            case "character_unlock":
                UnlockCharacter(_node.character);
                break;
                
            case "weapon_unlock":
                UnlockWeapon(_node.weapon);
                break;
                
            case "stat_boost":
                ApplyStatBoost(_node_id, _node);
                break;
                
            case "mod_unlock":
                UnlockModifier(_node.mod_key);
                break;
                
            case "level_unlock":
                UnlockLevel(_node.level_id);
                break;
                
            case "branch":
                // Branch nodes are just organizational
                break;
        }
    }
    
    /// @function ApplyStatBoost(_node_id, _node)
static ApplyStatBoost = function(_node_id, _node) {
    // Track stacking (using correct path)
    if (!variable_struct_exists(global.SaveData.career.skill_tree.node_stacks, _node_id)) {
        global.SaveData.career.skill_tree.node_stacks[$ _node_id] = 0;
    }
    
    var current_stacks = global.SaveData.career.skill_tree.node_stacks[$ _node_id];
    
    if (current_stacks < _node.max_stacks) {
        global.SaveData.career.skill_tree.node_stacks[$ _node_id] = current_stacks + 1;
        _node.current_stacks = current_stacks + 1;
        
        show_debug_message("Applied stat boost: " + _node.name + " (Stack " + string(_node.current_stacks) + "/" + string(_node.max_stacks) + ")");
    }
}
    
    // ==========================================
    // ANIMATION UPDATES
    // ==========================================
    
    /// @function UpdateUnlockAnimations()
    static UpdateUnlockAnimations = function() {
        for (var i = array_length(active_unlock_animations) - 1; i >= 0; i--) {
            var anim = active_unlock_animations[i];
            anim.timer++;
            
            if (anim.timer >= anim.duration) {
                array_delete(active_unlock_animations, i, 1);
            }
        }
    }
    
    // ==========================================
    // DRAW METHOD
    // ==========================================
    
    /// @function Draw(_w, _h, _cx, _cy, _player_souls)
    static Draw = function(_w, _h, _cx, _cy, _player_souls) {
        
        // Background
        draw_set_color(c_black);
        draw_set_alpha(0.9);
        draw_rectangle(0, 0, _w, _h, false);
        draw_set_alpha(1);
        
        // Draw connections first
        DrawConnections(_w, _h);
        
        // Draw nodes
        DrawNodes(_w, _h);
        
        // Draw info panel
        if (show_info_panel) {
            DrawInfoPanel(_w, _h, _player_souls);
        }
        
        // Draw controls
        DrawControls(_w, _h);
        
        draw_set_alpha(1);
    }
    
    /// @function DrawConnections(_w, _h)
static DrawConnections = function(_w, _h) {
    var node_keys = variable_struct_get_names(global.SkillTree);
    var drawn_connections = ds_map_create();
    
    for (var i = 0; i < array_length(node_keys); i++) {
        var key = node_keys[i];
        var node = global.SkillTree[$ key];
        
        if (!variable_struct_exists(node, "connections")) continue;
        
        var node_x = (node.position.x - camera_x) * camera_zoom + _w / 2;
        var node_y = (node.position.y - camera_y) * camera_zoom + _h / 2;
        
        for (var j = 0; j < array_length(node.connections); j++) {
            var conn_id = node.connections[j];
            
            // SAFETY CHECK: Make sure connected node exists
            if (!variable_struct_exists(global.SkillTree, conn_id)) {
                show_debug_message("WARNING: Node '" + key + "' references non-existent connection: '" + conn_id + "'");
                continue;
            }
            
            // Avoid drawing same connection twice
            var conn_key = key < conn_id ? (key + "_" + conn_id) : (conn_id + "_" + key);
            if (ds_map_exists(drawn_connections, conn_key)) continue;
            ds_map_set(drawn_connections, conn_key, true);
            
            var conn_node = global.SkillTree[$ conn_id];
            
            var conn_x = (conn_node.position.x - camera_x) * camera_zoom + _w / 2;
            var conn_y = (conn_node.position.y - camera_y) * camera_zoom + _h / 2;
            
            // Color based on unlock status
            var both_unlocked = node.unlocked && conn_node.unlocked;
            var line_color = both_unlocked ? connection_unlocked_color : connection_locked_color;
            var line_alpha = both_unlocked ? 0.8 : 0.3;
            
            draw_set_alpha(line_alpha);
            draw_line_width_color(node_x, node_y, conn_x, conn_y, 
                connection_thickness * camera_zoom, line_color, line_color);
        }
    }
    
    ds_map_destroy(drawn_connections);
    draw_set_alpha(1);
}
    
    /// @function DrawNodes(_w, _h)
    static DrawNodes = function(_w, _h) {
        var node_keys = variable_struct_get_names(global.SkillTree);
        
        // Draw non-selected nodes first
        for (var i = 0; i < array_length(node_keys); i++) {
            var key = node_keys[i];
            if (key == selected_node_id) continue;
            
            DrawNode(key, _w, _h, false);
        }
        
        // Draw selected node last (on top)
        if (selected_node_id != noone) {
            DrawNode(selected_node_id, _w, _h, true);
        }
    }
    
    /// @function DrawNode(_node_id, _w, _h, _is_selected)
    static DrawNode = function(_node_id, _w, _h, _is_selected) {
        var node = global.SkillTree[$ _node_id];
        
        var screen_x = (node.position.x - camera_x) * camera_zoom + _w / 2;
        var screen_y = (node.position.y - camera_y) * camera_zoom + _h / 2;
        
        // Skip if off-screen
        var margin = node_radius * 2;
        if (screen_x < -margin || screen_x > _w + margin || 
            screen_y < -margin || screen_y > _h + margin) {
            return;
        }
        
        var is_hovered = (hovered_node_id == _node_id);
        var can_afford = (GetSouls() >= node.cost);
        var can_unlock = CanUnlockNode(_node_id);
        
        // Determine color
        var node_color = c_gray;
        if (node.unlocked) {
            node_color = color_unlocked;
        } else if (can_unlock) {
            node_color = can_afford ? color_locked_available : color_locked_unavailable;
        } else {
            node_color = color_locked;
        }
        
        // Size
        var draw_radius = node_radius * camera_zoom;
        if (_is_selected) {
            draw_radius = node_selected_radius * camera_zoom;
        }
        if (is_hovered) {
            var pulse = sin(node_hover_pulse) * 0.1 + 1.0;
            draw_radius *= pulse;
        }
        
        // Glow for selected/hovered
        if (_is_selected || is_hovered) {
            draw_set_alpha(0.3);
            draw_set_color(_is_selected ? color_selected : color_hover);
            draw_circle(screen_x, screen_y, draw_radius * 1.3, false);
            draw_set_alpha(1);
        }
        
        // Node circle background
        draw_set_alpha(0.8);
        draw_set_color(c_black);
        draw_circle(screen_x, screen_y, draw_radius, false);
        draw_set_alpha(1);
        
        // Node border
        draw_set_color(node_color);
        draw_circle(screen_x, screen_y, draw_radius, true);
        draw_circle(screen_x, screen_y, draw_radius - 1, true);
        
        // Sprite
        if (variable_struct_exists(node, "sprite") && sprite_exists(node.sprite)) {
            var sprite_scale = (draw_radius / sprite_get_width(node.sprite));
            draw_sprite_ext(node.sprite, 0, screen_x, screen_y, 
                sprite_scale, sprite_scale, 0, c_white, 1);
        }
        
        // Unlock animations
        for (var i = 0; i < array_length(active_unlock_animations); i++) {
            var anim = active_unlock_animations[i];
            if (anim.node_id == _node_id) {
                var progress = anim.timer / anim.duration;
                var expand = (1 - progress) * 2;
                var anim_alpha = 1 - progress;
                
                draw_set_alpha(anim_alpha);
                draw_set_color(c_yellow);
                draw_circle(screen_x, screen_y, draw_radius * (1 + expand), true);
                draw_set_alpha(1);
            }
        }
        
        // Name label (only for selected/hovered)
        if (_is_selected || is_hovered) {
            draw_set_font(fnt_default);
            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            draw_set_color(c_white);
            
            var label_y = screen_y + draw_radius + 8;
            
            // Background
            var text_w = string_width(node.name);
            draw_set_alpha(0.7);
            draw_set_color(c_black);
            draw_rectangle(screen_x - text_w/2 - 4, label_y - 2,
                          screen_x + text_w/2 + 4, label_y + 14, false);
            draw_set_alpha(1);
            
            // Text
            draw_set_color(c_white);
            draw_text(screen_x, label_y, node.name);
        }
    }
    
    /// @function DrawInfoPanel(_w, _h, _player_souls)
    static DrawInfoPanel = function(_w, _h, _player_souls) {
        if (selected_node_id == noone) return;
        
        var node = global.SkillTree[$ selected_node_id];
        var panel_w = 300;
        var panel_h = 250;
        var panel_x = _w - panel_w - 20;
        var panel_y = 20;
        
        draw_set_alpha(info_panel_alpha * 0.9);
        
        // Background
        draw_set_color(c_black);
        draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
        
        // Border
        draw_set_color(c_white);
        draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);
        
        draw_set_alpha(info_panel_alpha);
        
        // Content
        var text_x = panel_x + 15;
        var text_y = panel_y + 15;
        
        draw_set_font(fnt_large);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_yellow);
        draw_text(text_x, text_y, node.name);
        
        text_y += 30;
        
        // Type badge
        draw_set_font(fnt_default);
        var type_text = GetNodeTypeText(node.type);
        var type_color = GetNodeTypeColor(node.type);
        draw_set_color(type_color);
        draw_text(text_x, text_y, "[" + type_text + "]");
        
        text_y += 25;
        
        // Description
        draw_set_color(c_ltgray);
        draw_text_ext(text_x, text_y, node.description, 16, panel_w - 30);
        
        text_y += 60;
        
        // Cost
        if (!node.unlocked) {
            draw_set_color(c_white);
            draw_text(text_x, text_y, "Cost: ");
            
            var can_afford = (_player_souls >= node.cost);
            draw_set_color(can_afford ? c_lime : c_red);
            draw_text(text_x + 50, text_y, string(node.cost) + " souls");
            
            text_y += 25;
        } else {
            draw_set_color(c_lime);
            draw_text(text_x, text_y, "UNLOCKED");
            text_y += 25;
        }
        
        // Requirements
        if (!node.unlocked && !CanUnlockNode(selected_node_id)) {
            draw_set_color(c_red);
            draw_text_ext(text_x, text_y, "Requires connected node", 16, panel_w - 30);
        }
        
        // Stack info for stat boosts
        if (node.type == "stat_boost" && variable_struct_exists(node, "max_stacks")) {
            text_y += 25;
            draw_set_color(c_aqua);
            draw_text(text_x, text_y, "Stack: " + string(node.current_stacks) + "/" + string(node.max_stacks));
        }
        
        draw_set_alpha(1);
    }
    
    /// @function DrawControls(_w, _h)
    static DrawControls = function(_w, _h) {
        var controls_x = 20;
        var controls_y = _h - 120;
        
        draw_set_font(fnt_default);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(0.7);
        
        // Background
        draw_set_color(c_black);
        draw_rectangle(controls_x - 5, controls_y - 5, controls_x + 300, controls_y + 95, false);
        
        draw_set_alpha(1);
        draw_set_color(c_white);
        
        var line_y = controls_y;
        draw_text(controls_x, line_y, "WASD/Arrows - Navigate"); line_y += 18;
        draw_text(controls_x, line_y, "Q/E - Zoom In/Out"); line_y += 18;
        draw_text(controls_x, line_y, "R - Reset View"); line_y += 18;
        draw_text(controls_x, line_y, "Right Click/Drag - Pan"); line_y += 18;
        draw_text(controls_x, line_y, "Enter - Unlock Node"); line_y += 18;
        draw_text(controls_x, line_y, "ESC - Back to Menu");
        
        // Souls display
        draw_set_halign(fa_right);
        draw_set_font(fnt_large);
        draw_set_color(c_yellow);
        draw_text(_w - 20, 20, "Souls: " + string(GetSouls()));
    }
    
    // ==========================================
    // HELPER METHODS
    // ==========================================
    
    /// @function GetNodeTypeText(_type)
    static GetNodeTypeText = function(_type) {
        switch (_type) {
            case "character_unlock": return "CHARACTER";
            case "weapon_unlock": return "WEAPON";
            case "stat_boost": return "STAT";
            case "mod_unlock": return "MODIFIER";
            case "level_unlock": return "LEVEL";
            case "branch": return "PATH";
            default: return "UNKNOWN";
        }
    }
    
    /// @function GetNodeTypeColor(_type)
    static GetNodeTypeColor = function(_type) {
        switch (_type) {
            case "character_unlock": return c_purple;
            case "weapon_unlock": return c_orange;
            case "stat_boost": return c_aqua;
            case "mod_unlock": return c_lime;
            case "level_unlock": return c_yellow;
            case "branch": return c_gray;
            default: return c_white;
        }
    }
}



/// @function DebugUnlockAllNodes()
function DebugUnlockAllNodes() {
    var node_keys = variable_struct_get_names(global.SkillTree);
    
    for (var i = 0; i < array_length(node_keys); i++) {
        var key = node_keys[i];
        var node = global.SkillTree[$ key];
        node.unlocked = true;
        
        if (!array_contains(global.SaveData.skill_tree.unlocked_nodes, key)) {
            array_push(global.SaveData.skill_tree.unlocked_nodes, key);
        }
    }
    
    SaveGame();
    show_debug_message("DEBUG: All skill tree nodes unlocked!");
}

/// @function DebugAddSouls(_amount)
function DebugAddSouls(_amount) {
    AddSouls(_amount);
    show_debug_message("DEBUG: Added " + string(_amount) + " souls!");
}

/// @function DebugResetSkillTree()
function DebugResetSkillTree() {
    global.SaveData.skill_tree.unlocked_nodes = ["root"];
    global.SaveData.skill_tree.node_stacks = {};
    
    var node_keys = variable_struct_get_names(global.SkillTree);
    for (var i = 0; i < array_length(node_keys); i++) {
        var key = node_keys[i];
        var node = global.SkillTree[$ key];
        node.unlocked = (key == "root");
        if (variable_struct_exists(node, "current_stacks")) {
            node.current_stacks = 0;
        }
    }
    
    SaveGame();
    show_debug_message("DEBUG: Skill tree reset!");
}