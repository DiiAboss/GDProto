/// @description Skill Tree - Meta Progression System
/// Players unlock nodes permanently, then select 5 active mods before each run
/// @description Skill Tree - Meta Progression System (IMPROVED LAYOUT)
/// Reorganized for cleaner connections and expanded content

/// @file scr_SkillTreeData.gml
/// @description Skill Tree - Meta Progression System
/// Pre-game modifiers, character unlocks, weapon unlocks, level unlocks

global.SkillTree = {
    
   // ==========================================
// ROOT - THE DEAL
// ==========================================
root: {
    id: "root",
    type: "soul_contract",  // NEW TYPE
    name: "SIGN THE CONTRACT",
    description: "TARLHS demands a soul.\nYours will do nicely.\n\n[Unlocks: Baseball Player, Menu Access]",
    cost: 0,
    unlocked: false,  // STARTS LOCKED
    position: {x: 400, y: 300},
    connections: ["arsenal_path", "pregame_path", "character_path", "level_path", "back_button_unlock", "soul_path"],
    sprite: spr_mod_default,
    grants_character: CharacterClass.BASEBALL_PLAYER
},

back_button_unlock: {
    id: "back_button_unlock",
    type: "utility_unlock",
    name: "ESCAPE CLAUSE",
    description: "The ability to leave.\nTARLHS is generous.\n\n...for a price.",
    cost: 1,
    unlocked: false,
    position: {x: 500, y: 380},
    connections: ["root", "prestige_path"],
    sprite: spr_mod_default,
    grants_back_button: true
},  



// ==========================================
// SOUTHWEST: SOUL PATH - Opposite of back_button
// Position: Left of root, branching down
// ==========================================

soul_path: {
    id: "soul_path",
    type: "branch",
    name: "Soul Harvesting",
    description: "Increase soul collection efficiency",
    cost: 50,
    unlocked: false,
    position: {x: 300, y: 380},  // Left and down from root
    connections: ["root", "soul_mult_1"],
    sprite: spr_mod_default
},

soul_mult_1: {
    id: "soul_mult_1",
    type: "stat_boost",
    name: "Soul Siphon I",
    description: "Souls collected are worth 1.25x",
    stat_key: "soul_mult",
    stat_value: 1.25,
    cost: 100,
    unlocked: false,
    position: {x: 200, y: 450},
    connections: ["soul_path", "soul_mult_2"],
    sprite: spr_mod_default,
    max_stacks: 1,
    current_stacks: 0
},

soul_mult_2: {
    id: "soul_mult_2",
    type: "stat_boost",
    name: "Soul Siphon II",
    description: "Souls collected are worth 1.5x",
    stat_key: "soul_mult",
    stat_value: 1.5,
    cost: 250,
    unlocked: false,
    position: {x: 100, y: 520},
    connections: ["soul_mult_1", "soul_mult_3"],
    sprite: spr_mod_default,
    max_stacks: 1,
    current_stacks: 0
},

soul_mult_3: {
    id: "soul_mult_3",
    type: "stat_boost",
    name: "Soul Siphon III",
    description: "Souls collected are worth 2x",
    stat_key: "soul_mult",
    stat_value: 2.0,
    cost: 500,
    unlocked: false,
    position: {x: 0, y: 590},
    connections: ["soul_mult_2", "soul_mult_4"],
    sprite: spr_mod_default,
    max_stacks: 1,
    current_stacks: 0
},

soul_mult_4: {
    id: "soul_mult_4",
    type: "stat_boost",
    name: "Soul Siphon IV",
    description: "Souls collected are worth 4x",
    stat_key: "soul_mult",
    stat_value: 4.0,
    cost: 1000,
    unlocked: false,
    position: {x: -100, y: 660},
    connections: ["soul_mult_3", "soul_mult_5"],
    sprite: spr_mod_default,
    max_stacks: 1,
    current_stacks: 0
},

soul_mult_5: {
    id: "soul_mult_5",
    type: "stat_boost",
    name: "Soul Siphon V",
    description: "Souls collected are worth 8x",
    stat_key: "soul_mult",
    stat_value: 8.0,
    cost: 5000,
    unlocked: false,
    position: {x: -200, y: 730},
    connections: ["soul_mult_4", "soul_mult_6"],
    sprite: spr_mod_default,
    max_stacks: 1,
    current_stacks: 0
},

soul_mult_6: {
    id: "soul_mult_6",
    type: "stat_boost",
    name: "Soul Siphon VI",
    description: "Souls collected are worth 16x",
    stat_key: "soul_mult",
    stat_value: 16.0,
    cost: 25000,
    unlocked: false,
    position: {x: -300, y: 800},
    connections: ["soul_mult_5"],
    sprite: spr_mod_default,
    max_stacks: 1,
    current_stacks: 0
},
    // ==========================================
    // NORTH: ARSENAL BRANCH - Weapon Categories
    // Position: Far North with sub-branches
    // ==========================================
    
    arsenal_path: {
        id: "arsenal_path",
        type: "branch",
        name: "Arsenal",
        description: "Unlock new weapons",
        cost: 50,
        unlocked: false,
        position: {x: 400, y: -100},
        connections: ["root", "blade_branch", "blunt_branch", "thrown_branch", "ranged_branch", "exotic_branch"],
        sprite: spr_mod_default
    },
    
    // BLADE WEAPONS (Left side of Arsenal)
    blade_branch: {
        id: "blade_branch",
        type: "branch",
        name: "Bladed Weapons",
        description: "Sharp and deadly",
        cost: 50,
        unlocked: false,
        position: {x: 100, y: -200},
        connections: ["arsenal_path", "dagger_unlock", "knife_unlock"],
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
        position: {x: 50, y: -300},
        connections: ["blade_branch"],
        sprite: spr_dagger
    },
    
    knife_unlock: {
        id: "knife_unlock",
        type: "weapon_unlock",
        name: "Unlock: Knife",
        description: "Quick slashing attacks",
        weapon: Weapon.Knife,
        cost: 200,
        unlocked: false,
        position: {x: 150, y: -300},
        connections: ["blade_branch", "throwing_knife_unlock"],
        sprite: spr_mod_default
    },
    
    throwing_knife_unlock: {
        id: "throwing_knife_unlock",
        type: "weapon_unlock",
        name: "Unlock: Throwing Knives",
        description: "Rapid projectile barrage",
        weapon: Weapon.ThrowingKnife,
        cost: 300,
        unlocked: false,
        position: {x: 150, y: -400},
        connections: ["knife_unlock"],
        sprite: spr_mod_default
    },
    
    // SWORDS (Center-left of Arsenal)
    sword_branch: {
        id: "sword_branch",
        type: "branch",
        name: "Swords",
        description: "The classics",
        cost: 50,
        unlocked: false,
        position: {x: 250, y: -200},
        connections: ["arsenal_path"],
        sprite: spr_mod_default
    },
    
    // Placeholder for future swords
    // longsword_unlock, greatsword_unlock, etc.
    
    // BLUNT WEAPONS (Center of Arsenal)
    blunt_branch: {
        id: "blunt_branch",
        type: "branch",
        name: "Blunt Weapons",
        description: "Crushing force",
        cost: 50,
        unlocked: false,
        position: {x: 400, y: -200},
        connections: ["arsenal_path", "club_unlock", "bat_unlock"],
        sprite: spr_mod_default
    },
    
    club_unlock: {
        id: "club_unlock",
        type: "weapon_unlock",
        name: "Unlock: Club",
        description: "Heavy overhead smash",
        weapon: Weapon.Club,
        cost: 250,
        unlocked: false,
        position: {x: 350, y: -300},
        connections: ["blunt_branch"],
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
        position: {x: 450, y: -300},
        connections: ["blunt_branch", "homerun_bat_unlock"],
        sprite: spr_way_better_bat
    },
    
    homerun_bat_unlock: {
        id: "homerun_bat_unlock",
        type: "weapon_unlock",
        name: "Unlock: Home Run Bat",
        description: "Maximum knockback power",
        weapon: Weapon.HomeRunBat,
        cost: 500,
        unlocked: false,
        position: {x: 450, y: -400},
        connections: ["bat_unlock"],
        sprite: spr_mod_default
    },
    
    // THROWN WEAPONS (Center-right of Arsenal)
    thrown_branch: {
        id: "thrown_branch",
        type: "branch",
        name: "Thrown Weapons",
        description: "Projectile power",
        cost: 50,
        unlocked: false,
        position: {x: 550, y: -200},
        connections: ["arsenal_path", "boomerang_unlock", "grenade_unlock"],
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
        position: {x: 500, y: -300},
        connections: ["thrown_branch", "bomberang_unlock"],
        sprite: spr_boomerang
    },
    
    bomberang_unlock: {
        id: "bomberang_unlock",
        type: "weapon_unlock",
        name: "Unlock: Bomberang",
        description: "Explosive boomerang",
        weapon: Weapon.Bomberang,
        cost: 500,
        unlocked: false,
        position: {x: 500, y: -400},
        connections: ["boomerang_unlock"],
        sprite: spr_mod_default
    },
    
    grenade_unlock: {
        id: "grenade_unlock",
        type: "weapon_unlock",
        name: "Unlock: Grenade",
        description: "AOE explosive damage",
        weapon: Weapon.Grenade,
        cost: 400,
        unlocked: false,
        position: {x: 600, y: -300},
        connections: ["thrown_branch"],
        sprite: spr_mod_default
    },
    
    holy_water_unlock: {
        id: "holy_water_unlock",
        type: "weapon_unlock",
        name: "Unlock: Holy Water",
        description: "Blessed projectile with area effect",
        weapon: Weapon.Holy_Water,
        cost: 450,
        unlocked: false,
        position: {x: 600, y: -400},
        connections: ["thrown_branch"],
        sprite: spr_holy_water
    },
    
    // RANGED WEAPONS (Right side of Arsenal)
    ranged_branch: {
        id: "ranged_branch",
        type: "branch",
        name: "Ranged Weapons",
        description: "Distance attacks",
        cost: 50,
        unlocked: false,
        position: {x: 700, y: -200},
        connections: ["arsenal_path", "bow_branch", "gun_branch"],
        sprite: spr_mod_default
    },
    
    // BOW SUB-BRANCH
    bow_branch: {
        id: "bow_branch",
        type: "branch",
        name: "Bows",
        description: "Precision archery",
        cost: 50,
        unlocked: false,
        position: {x: 650, y: -300},
        connections: ["ranged_branch"],
        sprite: spr_mod_default
    },
    
    // Placeholder for bow, crossbow, multi-bow
    
    // GUN SUB-BRANCH
    gun_branch: {
        id: "gun_branch",
        type: "branch",
        name: "Firearms",
        description: "Gunpowder weapons",
        cost: 50,
        unlocked: false,
        position: {x: 750, y: -300},
        connections: ["ranged_branch"],
        sprite: spr_mod_default
    },
    
    // Placeholder for flintlock, revolver, burst pistol, snakeshot
    
    // EXOTIC WEAPONS (Far right of Arsenal)
    exotic_branch: {
        id: "exotic_branch",
        type: "branch",
        name: "Exotic Weapons",
        description: "Rare and unusual",
        cost: 50,
        unlocked: false,
        position: {x: 850, y: -200},
        connections: ["arsenal_path"],
        sprite: spr_mod_default
    },
    
    // Placeholder for magic wands, crystal balls, weird stick, 
    // inhaler, charge cannon, black hole gun, bags of items, etc.
    
    // ==========================================
// CHARACTER PATH - Baseball Player is now from root
// ==========================================
character_path: {
    id: "character_path",
    type: "branch",
    name: "Champions",
    description: "Unlock new playable characters",
    cost: 50,
    unlocked: false,
    position: {x: 850, y: 300},
    connections: ["root", "priest_unlock", "alchemist_unlock", "assassin_unlock"],  // No baseball - it's from root
    sprite: spr_mod_default
},

priest_unlock: {
    id: "priest_unlock",
    type: "character_unlock",
    name: "Unlock: Priest",
    description: "Master of holy magic and area control",
    character: CharacterClass.PRIEST,
    cost: 800,
    unlocked: false,
    position: {x: 1000, y: 200},
    connections: ["character_path"],
    sprite: spr_vh_walk_south
},

alchemist_unlock: {
    id: "alchemist_unlock",
    type: "character_unlock",
    name: "Unlock: Alchemist",
    description: "Potion master and explosive expert",
    character: CharacterClass.ALCHEMIST,
    cost: 1000,
    unlocked: false,
    position: {x: 1000, y: 300},
    connections: ["character_path"],
    sprite: spr_Alchemist_South
},

assassin_unlock: {
    id: "assassin_unlock",
    type: "character_unlock",
    name: "Unlock: Assassin",
    description: "Critical strikes and high mobility",
    character: CharacterClass.ASSASSIN,
    cost: 1400,
    unlocked: false,
    position: {x: 1000, y: 400},
    connections: ["character_path"],
    sprite: spr_Assassin_South
},
    
    baseball_player_unlock: {
        id: "baseball_player_unlock",
        type: "character_unlock",
        name: "Unlock: Baseball Player",
        description: "Master of blunt weapons and home runs",
        character: CharacterClass.BASEBALL_PLAYER,
        cost: 1200,
        unlocked: false,
        position: {x: 1000, y: 400},
        connections: ["character_path"],
        sprite: spr_mod_default
    },
    
    alchemist_unlock: {
        id: "alchemist_unlock",
        type: "character_unlock",
        name: "Unlock: Alchemist",
        description: "Potion master and explosive expert",
        character: CharacterClass.ALCHEMIST,
        cost: 1400,
        unlocked: false,
        position: {x: 1000, y: 500},
        connections: ["character_path"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // SOUTH: LEVEL UNLOCKS
    // ==========================================
    
    level_path: {
        id: "level_path",
        type: "branch",
        name: "Arenas",
        description: "Unlock new battlegrounds",
        cost: 50,
        unlocked: false,
        position: {x: 400, y: 700},
        connections: ["root", "arena_2_unlock", "arena_3_unlock"],
        sprite: spr_mod_default
    },
    
    arena_2_unlock: {
        id: "arena_2_unlock",
        type: "level_unlock",
        name: "Unlock: Cursed Catacombs",
        description: "Harder enemies, better soul rewards",
        level_id: "arena_2",
        cost: 1500,
        unlocked: false,
        position: {x: 300, y: 850},
        connections: ["level_path"],
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
        position: {x: 500, y: 850},
        connections: ["level_path"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // WEST: PRE-GAME MODIFIER PATH
    // ==========================================
    
    pregame_path: {
        id: "pregame_path",
        type: "branch",
        name: "Pre-Game Advantages",
        description: "Permanent modifiers for all runs",
        cost: 50,
        unlocked: false,
        position: {x: -200, y: 300},
        connections: ["root", "pregame_physics_branch", "pregame_combat_branch", "pregame_movement_branch", "pregame_economy_branch"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // NORTHWEST: PHYSICS BRANCH
    // ==========================================
    
    pregame_physics_branch: {
        id: "pregame_physics_branch",
        type: "branch",
        name: "Physics Manipulators",
        description: "Change how entities interact",
        cost: 50,
        unlocked: false,
        position: {x: -400, y: 100},
        connections: ["pregame_path", "pregame_bouncy", "pregame_meteor", "pregame_heavy_hitter", "pregame_featherweight", "pregame_gravity_well"],
        sprite: spr_mod_default
    },
    
    pregame_bouncy: {
        id: "pregame_bouncy",
        type: "pregame_mod_unlock",
        name: "Bouncy Castle",
        description: "All entities have 50% increased knockback",
        mod_id: PreGameMod.BOUNCY,
        cost: 500,
        unlocked: false,
        position: {x: -550, y: 50},
        connections: ["pregame_physics_branch"],
        sprite: spr_mod_default
    },
    
    pregame_meteor: {
        id: "pregame_meteor",
        type: "pregame_mod_unlock",
        name: "Meteor Strike",
        description: "Enemies that hit walls at high speed explode",
        mod_id: PreGameMod.METEOR,
        cost: 600,
        unlocked: false,
        position: {x: -550, y: 150},
        connections: ["pregame_physics_branch"],
        sprite: spr_mod_default
    },
    
    pregame_heavy_hitter: {
        id: "pregame_heavy_hitter",
        type: "pregame_mod_unlock",
        name: "Heavy Hitter",
        description: "Attacks 30% slower but knock enemies 3x farther",
        mod_id: PreGameMod.HEAVY_HITTER,
        cost: 550,
        unlocked: false,
        position: {x: -450, y: 0},
        connections: ["pregame_physics_branch"],
        sprite: spr_mod_default
    },
    
    pregame_featherweight: {
        id: "pregame_featherweight",
        type: "pregame_mod_unlock",
        name: "Featherweight",
        description: "Move 25% faster, attacks knock enemies 50% less",
        mod_id: PreGameMod.FEATHERWEIGHT,
        cost: 500,
        unlocked: false,
        position: {x: -350, y: 0},
        connections: ["pregame_physics_branch"],
        sprite: spr_mod_default
    },
    
    pregame_gravity_well: {
        id: "pregame_gravity_well",
        type: "pregame_mod_unlock",
        name: "Gravity Well",
        description: "Killed enemies pull nearby enemies toward death location",
        mod_id: PreGameMod.GRAVITY_WELL,
        cost: 650,
        unlocked: false,
        position: {x: -450, y: 200},
        connections: ["pregame_physics_branch"],
        sprite: spr_mod_default
    },
    
    pregame_ice_rink: {
        id: "pregame_ice_rink",
        type: "pregame_mod_unlock",
        name: "Ice Rink",
        description: "All entities slide after moving (momentum physics)",
        mod_id: PreGameMod.ICE_RINK,
        cost: 600,
        unlocked: false,
        position: {x: -350, y: 200},
        connections: ["pregame_physics_branch"],
        sprite: spr_mod_default
    },
    
    pregame_pinball_mode: {
        id: "pregame_pinball_mode",
        type: "pregame_mod_unlock",
        name: "Pinball Wizard",
        description: "Enemies bounce off screen edges",
        mod_id: PreGameMod.PINBALL_MODE,
        cost: 700,
        unlocked: false,
        position: {x: -400, y: -50},
        connections: ["pregame_physics_branch"],
        sprite: spr_mod_default
    },
    
    pregame_dash_strike: {
        id: "pregame_dash_strike",
        type: "pregame_mod_unlock",
        name: "Dash Strike",
        description: "Dashing through enemies sends them flying and deals damage",
        mod_id: PreGameMod.DASH_STRIKE,
        cost: 550,
        unlocked: false,
        position: {x: -300, y: 100},
        connections: ["pregame_physics_branch"],
        sprite: spr_mod_default
    },
    
    pregame_big_weapon: {
        id: "pregame_big_weapon",
        type: "pregame_mod_unlock",
        name: "Heavyweight Champion",
        description: "Weapons are 2x bigger but 1.5x slower",
        mod_id: PreGameMod.BIG_WEAPON,
        cost: 650,
        unlocked: false,
        position: {x: -500, y: 100},
        connections: ["pregame_physics_branch"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // NORTH FROM PREGAME: MOVEMENT BRANCH (Straight up)
    // ==========================================
    
    pregame_movement_branch: {
        id: "pregame_movement_branch",
        type: "branch",
        name: "Movement & Utility",
        description: "Enhance mobility and utility",
        cost: 50,
        unlocked: false,
        position: {x: -200, y: -100},
        connections: ["pregame_path", "pregame_time_slow", "pregame_speed_demon", "pregame_teleport", "pregame_hover_boots"],
        sprite: spr_mod_default
    },
    
    pregame_time_slow: {
        id: "pregame_time_slow",
        type: "pregame_mod_unlock",
        name: "Bullet Time",
        description: "Dash = 5s bullet time (10s cooldown). You move normal speed",
        mod_id: PreGameMod.TIME_SLOW,
        cost: 800,
        unlocked: false,
        position: {x: -250, y: -250},
        connections: ["pregame_movement_branch"],
        sprite: spr_mod_default
    },
    
    pregame_hover_boots: {
        id: "pregame_hover_boots",
        type: "pregame_mod_unlock",
        name: "Hover Boots",
        description: "Float over pits before falling",
        mod_id: PreGameMod.HOVER_BOOTS,
        cost: 500,
        unlocked: false,
        position: {x: -150, y: -250},
        connections: ["pregame_movement_branch"],
        sprite: spr_mod_default
    },
    
    pregame_teleport: {
        id: "pregame_teleport",
        type: "pregame_mod_unlock",
        name: "Blink",
        description: "Dash = short teleport (no i-frames)",
        mod_id: PreGameMod.TELEPORT,
        cost: 700,
        unlocked: false,
        position: {x: -200, y: -350},
        connections: ["pregame_movement_branch"],
        sprite: spr_mod_default
    },
    
    pregame_speed_demon: {
        id: "pregame_speed_demon",
        type: "pregame_mod_unlock",
        name: "Speed Demon",
        description: "+50% move speed, -50% HP and weight",
        mod_id: PreGameMod.SPEED_DEMON,
        cost: 650,
        unlocked: false,
        position: {x: -300, y: -200},
        connections: ["pregame_movement_branch"],
        sprite: spr_mod_default
    },
    
    pregame_magnetic_field: {
        id: "pregame_magnetic_field",
        type: "pregame_mod_unlock",
        name: "Magnetic Field",
        description: "Pickups pulled from 2x farther",
        mod_id: PreGameMod.MAGNETIC_FIELD,
        cost: 450,
        unlocked: false,
        position: {x: -100, y: -200},
        connections: ["pregame_movement_branch"],
        sprite: spr_mod_default
    },
    
    pregame_charge_dash: {
        id: "pregame_charge_dash",
        type: "pregame_mod_unlock",
        name: "Charge Dash",
        description: "Hold dash to charge, release to launch",
        mod_id: PreGameMod.CHARGE_DASH,
        cost: 750,
        unlocked: false,
        position: {x: -250, y: -150},
        connections: ["pregame_movement_branch"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // SOUTHWEST: COMBAT BRANCH
    // ==========================================
    
    pregame_combat_branch: {
        id: "pregame_combat_branch",
        type: "branch",
        name: "Combat Modifiers",
        description: "Enhance your damage and abilities",
        cost: 50,
        unlocked: false,
        position: {x: -400, y: 500},
        connections: ["pregame_path", "pregame_glass_cannon", "pregame_berserk", "pregame_crit_addict", "pregame_auto_aim"],
        sprite: spr_mod_default
    },
    
    pregame_glass_cannon: {
        id: "pregame_glass_cannon",
        type: "pregame_mod_unlock",
        name: "Glass Cannon",
        description: "Deal 2x damage but have 50% HP",
        mod_id: PreGameMod.GLASS_CANNON,
        cost: 600,
        unlocked: false,
        position: {x: -550, y: 450},
        connections: ["pregame_combat_branch"],
        sprite: spr_mod_default
    },
    
    pregame_auto_aim: {
        id: "pregame_auto_aim",
        type: "pregame_mod_unlock",
        name: "Auto Aim",
        description: "Projectiles home toward nearest enemy",
        mod_id: PreGameMod.AUTO_AIM,
        cost: 550,
        unlocked: false,
        position: {x: -350, y: 600},
        connections: ["pregame_combat_branch"],
        sprite: spr_mod_default
    },
    
    pregame_dual_wield: {
        id: "pregame_dual_wield",
        type: "pregame_mod_unlock",
        name: "Dual Wield",
        description: "Secondary weapon activates with right click",
        mod_id: PreGameMod.DUAL_WIELD,
        cost: 700,
        unlocked: false,
        position: {x: -450, y: 600},
        connections: ["pregame_combat_branch"],
        sprite: spr_mod_default
    },
    
    pregame_lifesteal: {
        id: "pregame_lifesteal",
        type: "pregame_mod_unlock",
        name: "Vampiric",
        description: "Heal 1% of damage dealt, drain 0.33 HP/sec",
        mod_id: PreGameMod.LIFESTEAL,
        cost: 500,
        unlocked: false,
        position: {x: -550, y: 550},
        connections: ["pregame_combat_branch"],
        sprite: spr_mod_default
    },
    
    pregame_ricochet: {
        id: "pregame_ricochet",
        type: "pregame_mod_unlock",
        name: "Ricochet",
        description: "Projectiles bounce off walls and enemies",
        mod_id: PreGameMod.RICOCHET,
        cost: 600,
        unlocked: false,
        position: {x: -300, y: 500},
        connections: ["pregame_combat_branch"],
        sprite: spr_mod_default
    },
    
    pregame_berserk: {
        id: "pregame_berserk",
        type: "pregame_mod_unlock",
        name: "Berserk",
        description: "Start 50% damage. At 1% HP, 3x damage (scales with missing HP)",
        mod_id: PreGameMod.BERSERK,
        cost: 650,
        unlocked: false,
        position: {x: -450, y: 400},
        connections: ["pregame_combat_branch"],
        sprite: spr_mod_default
    },
    
    pregame_execute_base: {
        id: "pregame_execute_base",
        type: "pregame_mod_unlock",
        name: "Executioner",
        description: "Instantly kill base enemies below 20% HP",
        mod_id: PreGameMod.EXECUTE_BASE,
        cost: 700,
        unlocked: false,
        position: {x: -500, y: 650},
        connections: ["pregame_combat_branch", "pregame_execute_boss"],
        sprite: spr_mod_default
    },
    
    pregame_execute_boss: {
        id: "pregame_execute_boss",
        type: "pregame_mod_unlock",
        name: "Regicide",
        description: "Instantly kill boss enemies below 20% HP",
        mod_id: PreGameMod.EXECUTE_BOSS,
        cost: 1000,
        unlocked: false,
        position: {x: -500, y: 750},
        connections: ["pregame_execute_base"],
        sprite: spr_mod_default
    },
    
    pregame_crit_addict: {
        id: "pregame_crit_addict",
        type: "pregame_mod_unlock",
        name: "Crit Addict",
        description: "50% crit chance, normal attacks -30% damage",
        mod_id: PreGameMod.CRIT_ADDICT,
        cost: 650,
        unlocked: false,
        position: {x: -350, y: 400},
        connections: ["pregame_combat_branch"],
        sprite: spr_mod_default
    },
    
    pregame_multi_hit: {
        id: "pregame_multi_hit",
        type: "pregame_mod_unlock",
        name: "Double Tap",
        description: "Attacks hit twice, 50% damage each",
        mod_id: PreGameMod.MULTI_HIT,
        cost: 600,
        unlocked: false,
        position: {x: -300, y: 400},
        connections: ["pregame_combat_branch"],
        sprite: spr_mod_default
    },
    
    pregame_sharpshooter: {
        id: "pregame_sharpshooter",
        type: "pregame_mod_unlock",
        name: "Sharpshooter",
        description: "+100% damage to enemies off-screen",
        mod_id: PreGameMod.SHARPSHOOTER,
        cost: 550,
        unlocked: false,
        position: {x: -400, y: 650},
        connections: ["pregame_combat_branch"],
        sprite: spr_mod_default
    },
    
    // ==========================================
    // SOUTH FROM PREGAME: ECONOMY BRANCH (Straight down)
    // ==========================================
    
    pregame_economy_branch: {
        id: "pregame_economy_branch",
        type: "branch",
        name: "Economy & Progression",
        description: "Boost rewards and growth",
        cost: 50,
        unlocked: false,
        position: {x: -200, y: 700},
        connections: ["pregame_path", "pregame_souls_2x", "pregame_lucky", "pregame_investor", "pregame_stat_hp"],
        sprite: spr_mod_default
    },
    
    pregame_souls_2x: {
        id: "pregame_souls_2x",
        type: "pregame_mod_unlock",
        name: "Soul Harvest",
        description: "Earn 2x souls per run",
        mod_id: PreGameMod.SOULS_2X,
        cost: 50,
        unlocked: false,
        position: {x: -150, y: 850},
        connections: ["pregame_economy_branch"],
        sprite: spr_mod_default
    },
    
    pregame_exp_2x: {
        id: "pregame_exp_2x",
        type: "pregame_mod_unlock",
        name: "Adrenaline Rush",
        description: "2x EXP, expires after 10 seconds",
        mod_id: PreGameMod.EXP_2X,
        cost: 400,
        unlocked: false,
        position: {x: -250, y: 850},
        connections: ["pregame_economy_branch"],
        sprite: spr_mod_default
    },
    
    pregame_lucky: {
        id: "pregame_lucky",
        type: "pregame_mod_unlock",
        name: "Lucky",
        description: "50% increased drop rates",
        mod_id: PreGameMod.LUCKY,
        cost: 500,
        unlocked: false,
        position: {x: -200, y: 950},
        connections: ["pregame_economy_branch"],
        sprite: spr_mod_default
    },
    
    pregame_random_mod: {
        id: "pregame_random_mod",
        type: "pregame_mod_unlock",
        name: "Wild Card",
        description: "Start with random in-game mod (Lvl 1-5)",
        mod_id: PreGameMod.RANDOM_MOD,
        cost: 600,
        unlocked: false,
        position: {x: -100, y: 950},
        connections: ["pregame_economy_branch"],
        sprite: spr_mod_default
    },
    
    pregame_stat_hp: {
        id: "pregame_stat_hp",
        type: "pregame_mod_unlock",
        name: "Vitality Boost",
        description: "+10% Max HP",
        mod_id: PreGameMod.STAT_HP,
        cost: 300,
        unlocked: false,
        position: {x: -100, y: 750},
        connections: ["pregame_economy_branch"],
        sprite: spr_mod_default
    },
    
    pregame_stat_damage: {
        id: "pregame_stat_damage",
        type: "pregame_mod_unlock",
        name: "Power Boost",
        description: "+10% Damage",
        mod_id: PreGameMod.STAT_DAMAGE,
        cost: 300,
        unlocked: false,
        position: {x: -200, y: 800},
        connections: ["pregame_economy_branch"],
        sprite: spr_mod_default
    },
    
    pregame_stat_speed: {
        id: "pregame_stat_speed",
        type: "pregame_mod_unlock",
        name: "Agility Boost",
        description: "+10% Move Speed",
        mod_id: PreGameMod.STAT_SPEED,
        cost: 300,
        unlocked: false,
        position: {x: -300, y: 750},
        connections: ["pregame_economy_branch"],
        sprite: spr_mod_default
    },
    
    pregame_investor: {
        id: "pregame_investor",
        type: "pregame_mod_unlock",
        name: "Investor",
        description: "Gold generates 1% interest/sec (max 2x)",
        mod_id: PreGameMod.INVESTOR,
        cost: 700,
        unlocked: false,
        position: {x: -100, y: 850},
        connections: ["pregame_economy_branch", "pregame_compounding"],
        sprite: spr_mod_default
    },
    
    pregame_compounding: {
        id: "pregame_compounding",
        type: "pregame_mod_unlock",
        name: "Compounding Interest",
        description: "Each kill +1% soul gain (stacks infinitely)",
        mod_id: PreGameMod.COMPOUNDING,
        cost: 800,
        unlocked: false,
        position: {x: 0, y: 950},
        connections: ["pregame_investor"],
        sprite: spr_mod_default
    },
    
    // ==========================================
// PRESTIGE - FAR AWAY, EXPENSIVE
// ==========================================
prestige_path: {
    id: "prestige_path",
    type: "branch",
    name: "BUY BACK YOUR SOUL",
    description: "Freedom has a price.\nTARLHS always collects.\n\n1,000,000 souls.",
    cost: 1000000,
    unlocked: false,
    position: {x: 700, y: 380},
    connections: ["back_button_unlock"],
    sprite: spr_mod_default
},
    
    // Prestige nodes will go here later
};

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
    pan_max_x = 1400;
    pan_min_y = -500;
    pan_max_y = 1000;
    tarlhs_dismiss_cooldown = 0;  // ADD THIS
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
    // TARLHS MESSAGE SYSTEM
    // ==========================================
    tarlhs_message_active = false;
    tarlhs_message_timer = 0;
    tarlhs_message_text = "";
    tarlhs_message_subtext = "";
    
    // ==========================================
    // UPDATE METHOD
    // ==========================================
    
    /// @function Update(_input, _mx, _my, _player_souls)
    static Update = function(_input, _mx, _my, _player_souls) {
        
        node_hover_pulse += pulse_speed;
        
        UpdateUnlockAnimations();
       // At the START of Update(), tick down cooldown
if (tarlhs_dismiss_cooldown > 0) {
    tarlhs_dismiss_cooldown--;
} 
// Update TARLHS message timer & input
if (tarlhs_message_active) {
    tarlhs_message_timer--;
    
    // Allow dismissing with Escape or Back (but only if root is unlocked)
    if (_input.Back || _input.Escape) {
        if (global.SkillTree.root.unlocked) {
            // Dismiss the message
            tarlhs_message_active = false;
            tarlhs_message_timer = 0;
            tarlhs_dismiss_cooldown = 10;  // Prevent re-showing for 10 frames
            return;
        }
    }
    
    // Auto-dismiss when timer runs out
    if (tarlhs_message_timer <= 0) {
        tarlhs_message_active = false;
    }
    
    return;
}
        
        info_panel_alpha = lerp(info_panel_alpha, info_panel_target_alpha, 0.1);
        
        if (navigation_cooldown > 0) navigation_cooldown--;
        
        HandleMouseInteraction(_input, _mx, _my);
        HandleKeyboardNavigation(_input);
        HandleZoom(_input);
        
        camera_x = lerp(camera_x, camera_target_x, camera_smooth_speed);
        camera_y = lerp(camera_y, camera_target_y, camera_smooth_speed);
        camera_zoom = lerp(camera_zoom, camera_target_zoom, camera_smooth_speed * 0.5);
        
        // Unlock with Action (Space), Reload (E), or Enter
if (_input.Action || _input.Reload || keyboard_check_pressed(vk_enter)) {
    TryUnlockNode(selected_node_id, _player_souls);
}
    }
    
    // ==========================================
    // TARLHS MESSAGES
    // ==========================================
    
/// @function ShowEscapeBlockedMessage()
static ShowEscapeBlockedMessage = function() {
    
// Don't show if we just dismissed
    if (tarlhs_dismiss_cooldown > 0) return;
    
    tarlhs_message_active = true;
    tarlhs_message_timer = 300;
    
    // Different messages based on progress
    if (!global.SkillTree.root.unlocked) {
        // Haven't signed contract yet
        tarlhs_message_text = choose(
            "You cannot leave without signing.",
            "TARLHS demands your signature first.",
            "The contract awaits. You cannot flee.",
            "Sign... or remain here forever."
        );
        tarlhs_message_subtext = "[ Sign the contract to proceed ]";
        
        // Focus on root
        selected_node_id = "root";
        CenterCameraOnNode("root");
    } else {
        // Signed but no escape clause
        tarlhs_message_text = choose(
            "You haven't unlocked the ability to leave yet...",
            "TARLHS does not permit escape.",
            "The exit is... elsewhere.",
            "Looking for a way out? How predictable.",
            "One soul. That's all it costs to leave."
        );
        tarlhs_message_subtext = "[ Press ESC to dismiss | ESCAPE CLAUSE: 1 soul ]";
        
        // Reveal and focus the back button node
        RevealBackButtonNode();
        
        // SELECT the back button node so player can just hit Enter
        selected_node_id = "back_button_unlock";
        CenterCameraOnNode("back_button_unlock");
    }
}
    
    /// @function RevealBackButtonNode()
    static RevealBackButtonNode = function() {
        // Mark it as revealed in tutorial data
        global.SaveData.career.tutorial.back_node_revealed = true;
        
        // Pan camera toward it
        if (variable_struct_exists(global.SkillTree, "back_button_unlock")) {
            var node = global.SkillTree.back_button_unlock;
            camera_target_x = lerp(camera_target_x, node.position.x, 0.5);
            camera_target_y = lerp(camera_target_y, node.position.y, 0.5);
        }
    }
    
    // ==========================================
    // NODE VISIBILITY
    // ==========================================
    
    /// @function IsNodeVisible(_node_id)
    /// @desc Returns true if node should be drawn
    static IsNodeVisible = function(_node_id) {
        var node = global.SkillTree[$ _node_id];
        
        // Root is always visible
        if (_node_id == "root") return true;
        
        // Already unlocked = visible
        if (node.unlocked) return true;
        
        // Special case: back_button_unlock only visible after revealed
        if (_node_id == "back_button_unlock") {
            return global.SaveData.career.tutorial.back_node_revealed ?? false;
        }
        
        // Special case: prestige_path only visible after back_button purchased
        if (_node_id == "prestige_path") {
            return global.SaveData.career.tutorial.back_button_unlocked ?? false;
        }
        
        // Check if ANY connected node is unlocked (then we're visible)
        if (variable_struct_exists(node, "connections")) {
            for (var i = 0; i < array_length(node.connections); i++) {
                var conn_id = node.connections[i];
                if (!variable_struct_exists(global.SkillTree, conn_id)) continue;
                
                var conn_node = global.SkillTree[$ conn_id];
                if (conn_node.unlocked) return true;
            }
        }
        
        return false;
    }
    
    /// @function IsConnectionVisible(_node_id_a, _node_id_b)
    static IsConnectionVisible = function(_node_id_a, _node_id_b) {
        // Connection visible if BOTH nodes are visible
        return IsNodeVisible(_node_id_a) && IsNodeVisible(_node_id_b);
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
        
        // Check node hover - ONLY VISIBLE NODES
        hovered_node_id = noone;
        var node_keys = variable_struct_get_names(global.SkillTree);
        
        for (var i = 0; i < array_length(node_keys); i++) {
            var key = node_keys[i];
            
            // Skip invisible nodes
            if (!IsNodeVisible(key)) continue;
            
            var node = global.SkillTree[$ key];
            
            var screen_x = (node.position.x - camera_x) * camera_zoom + gui_w / 2;
            var screen_y = (node.position.y - camera_y) * camera_zoom + gui_h / 2;
            
            var check_radius = node_radius * camera_zoom;
            
            if (point_distance(_mx, _my, screen_x, screen_y) < check_radius) {
                hovered_node_id = key;
                
                if (_input.FirePress) {
    if (selected_node_id == key) {
        // Already selected - try to unlock it
        TryUnlockNode(key, GetSouls());
    } else {
        // Select this node
        selected_node_id = key;
        CenterCameraOnNode(key);
    }
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
        
        if (_input.UpPress || _input.DownPress || _input.LeftPress || _input.RightPress) {
            
            var target_angle = 0;
            if (_input.UpPress) target_angle = 270;
            else if (_input.DownPress) target_angle = 90;
            else if (_input.LeftPress) target_angle = 180;
            else if (_input.RightPress) target_angle = 0;
            
            for (var i = 0; i < array_length(current_node.connections); i++) {
                var conn_id = current_node.connections[i];
                
                // Skip non-existent nodes
                if (!variable_struct_exists(global.SkillTree, conn_id)) continue;
                
                // Skip invisible nodes
                if (!IsNodeVisible(conn_id)) continue;
                
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
        var wheel = mouse_wheel_up() - mouse_wheel_down();
        if (wheel != 0) {
            camera_target_zoom = clamp(camera_target_zoom + wheel * 0.1, camera_min_zoom, camera_max_zoom);
        }
        
        if (keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(vk_pageup)) {
            camera_target_zoom = clamp(camera_target_zoom + 0.2, camera_min_zoom, camera_max_zoom);
        }
        if (keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_pagedown)) {
            camera_target_zoom = clamp(camera_target_zoom - 0.2, camera_min_zoom, camera_max_zoom);
        }
        
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
        
        // Add to save data
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
        
        // Root is always available (the initial contract)
        if (_node_id == "root") return true;
        
        // Check if any connected nodes are unlocked
        if (!variable_struct_exists(node, "connections")) return false;
        
        for (var i = 0; i < array_length(node.connections); i++) {
            var conn_id = node.connections[i];
            
            if (!variable_struct_exists(global.SkillTree, conn_id)) continue;
            
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
            case "soul_contract":
                // The root contract - grants menu + first character
                global.SaveData.career.tutorial.soul_sold = true;
                global.SaveData.career.tutorial.menu_unlocked = true;
                
                if (variable_struct_exists(_node, "grants_character")) {
                    UnlockCharacter(_node.grants_character);
                }
                show_debug_message("TARLHS: Your soul is mine. Welcome.");
                break;
                
            case "utility_unlock":
                // Back button, etc.
                if (variable_struct_exists(_node, "grants_back_button") && _node.grants_back_button) {
                    global.SaveData.career.tutorial.back_button_unlocked = true;
                    show_debug_message("TARLHS: You may leave... for now.");
                }
                break;
                
            case "character_unlock":
                UnlockCharacter(_node.character);
                break;
                
            case "weapon_unlock":
                UnlockWeapon(_node.weapon);
                break;
                
            case "stat_boost":
                ApplyStatBoost(_node_id, _node);
				 // Special: If this is a soul multiplier, save it to career data
    if (variable_struct_exists(_node, "stat_key") && _node.stat_key == "soul_mult") {
        global.SaveData.career.soul_multiplier = _node.stat_value;
        SaveGame();
    }
                break;
                
            case "pregame_mod_unlock":
                UnlockModifier(_node.id);
                break;
                
            case "level_unlock":
                UnlockLevel(_node.level_id);
                break;
                
            case "branch":
                // Organizational only
                break;
        }
    }
    
    /// @function ApplyStatBoost(_node_id, _node)
    static ApplyStatBoost = function(_node_id, _node) {
        if (!variable_struct_exists(global.SaveData.career.skill_tree.node_stacks, _node_id)) {
            global.SaveData.career.skill_tree.node_stacks[$ _node_id] = 0;
        }
        
        var current_stacks = global.SaveData.career.skill_tree.node_stacks[$ _node_id];
        
        if (current_stacks < _node.max_stacks) {
            global.SaveData.career.skill_tree.node_stacks[$ _node_id] = current_stacks + 1;
            _node.current_stacks = current_stacks + 1;
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
        
        // Draw connections first (only visible ones)
        DrawConnections(_w, _h);
        
        // Draw nodes (only visible ones)
        DrawNodes(_w, _h);
        
        // Draw info panel
        if (show_info_panel) {
            DrawInfoPanel(_w, _h, _player_souls);
        }
        
        // Draw tutorial arrow if root not unlocked
        if (!global.SkillTree.root.unlocked) {
            DrawTutorialArrow(_w, _h);
        }
        
        // Draw TARLHS message
        if (tarlhs_message_active) {
            DrawTarlhsMessage(_w, _h);
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
            
            // Skip invisible nodes
            if (!IsNodeVisible(key)) continue;
            
            if (!variable_struct_exists(node, "connections")) continue;
            
            var node_x = (node.position.x - camera_x) * camera_zoom + _w / 2;
            var node_y = (node.position.y - camera_y) * camera_zoom + _h / 2;
            
            for (var j = 0; j < array_length(node.connections); j++) {
                var conn_id = node.connections[j];
                
                // Skip non-existent or invisible connections
                if (!variable_struct_exists(global.SkillTree, conn_id)) continue;
                if (!IsConnectionVisible(key, conn_id)) continue;
                
                // Avoid drawing same connection twice
                var conn_key = key < conn_id ? (key + "_" + conn_id) : (conn_id + "_" + key);
                if (ds_map_exists(drawn_connections, conn_key)) continue;
                ds_map_set(drawn_connections, conn_key, true);
                
                var conn_node = global.SkillTree[$ conn_id];
                
                var conn_x = (conn_node.position.x - camera_x) * camera_zoom + _w / 2;
                var conn_y = (conn_node.position.y - camera_y) * camera_zoom + _h / 2;
                
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
        
        // Draw non-selected visible nodes first
        for (var i = 0; i < array_length(node_keys); i++) {
            var key = node_keys[i];
            if (key == selected_node_id) continue;
            if (!IsNodeVisible(key)) continue;
            
            DrawNode(key, _w, _h, false);
        }
        
        // Draw selected node last (on top) if visible
        if (selected_node_id != noone && IsNodeVisible(selected_node_id)) {
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
            
            var text_w = string_width(node.name);
            draw_set_alpha(0.7);
            draw_set_color(c_black);
            draw_rectangle(screen_x - text_w/2 - 4, label_y - 2,
                          screen_x + text_w/2 + 4, label_y + 14, false);
            draw_set_alpha(1);
            
            draw_set_color(c_white);
            draw_text(screen_x, label_y, node.name);
        }
    }
    
    /// @function DrawTutorialArrow(_w, _h)
    static DrawTutorialArrow = function(_w, _h) {
        var root = global.SkillTree.root;
        var screen_x = (root.position.x - camera_x) * camera_zoom + _w / 2;
        var screen_y = (root.position.y - camera_y) * camera_zoom + _h / 2;
        
        var pulse = sin(current_time * 0.005) * 10;
        var arrow_y = screen_y - 80 - pulse;
        
        // Arrow triangle
        draw_set_color(c_yellow);
        draw_triangle(
            screen_x, arrow_y + 30,
            screen_x - 15, arrow_y,
            screen_x + 15, arrow_y,
            false
        );
        
        // Text
        draw_set_font(fnt_large);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_color(c_yellow);
        draw_text(screen_x, arrow_y - 10, "SIGN HERE");
        
        draw_set_font(fnt_default);
        draw_set_color(c_ltgray);
        draw_text(screen_x, arrow_y + 5, "(Press ENTER or Click)");
    }
/// @function DrawTarlhsMessage(_w, _h)
static DrawTarlhsMessage = function(_w, _h) {
    var msg_w = 500;
    var msg_h = 140;
    var msg_x = _w/2 - msg_w/2;
    var msg_y = 30;  // TOP of screen instead of bottom
    
    // Darken background slightly (less opacity so node is visible)
    draw_set_alpha(0.4);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    
    // Message box
    draw_set_color(c_black);
    draw_rectangle(msg_x, msg_y, msg_x + msg_w, msg_y + msg_h, false);
    draw_set_color(c_red);
    draw_rectangle(msg_x, msg_y, msg_x + msg_w, msg_y + msg_h, true);
    draw_rectangle(msg_x + 2, msg_y + 2, msg_x + msg_w - 2, msg_y + msg_h - 2, true);
    
    // TARLHS name
    draw_set_font(fnt_large);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_red);
    draw_text(msg_x + 20, msg_y + 15, "TARLHS");
    
    // Message
    draw_set_font(fnt_default);
    draw_set_color(c_white);
    draw_text_ext(msg_x + 20, msg_y + 50, tarlhs_message_text, 20, msg_w - 40);
    
    // Subtext - pulsing for visibility
    var pulse = 0.7 + sin(current_time * 0.005) * 0.3;
    draw_set_halign(fa_center);
    draw_set_alpha(pulse);
    draw_set_color(c_yellow);
    draw_text(msg_x + msg_w/2, msg_y + msg_h - 25, tarlhs_message_subtext);
    
    draw_set_halign(fa_left);
    draw_set_alpha(1);
}
    
    /// @function DrawInfoPanel(_w, _h, _player_souls)
    static DrawInfoPanel = function(_w, _h, _player_souls) {
        if (selected_node_id == noone) return;
        if (!IsNodeVisible(selected_node_id)) return;
        
        var node = global.SkillTree[$ selected_node_id];
        var panel_w = 300;
        var panel_h = 250;
        var panel_x = _w - panel_w - 20;
        var panel_y = 20;
        
        draw_set_alpha(info_panel_alpha * 0.9);
        
        draw_set_color(c_black);
        draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
        
        draw_set_color(c_white);
        draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);
        
        draw_set_alpha(info_panel_alpha);
        
        var text_x = panel_x + 15;
        var text_y = panel_y + 15;
        
        draw_set_font(fnt_large);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_yellow);
        draw_text(text_x, text_y, node.name);
        
        text_y += 30;
        
        draw_set_font(fnt_default);
        var type_text = GetNodeTypeText(node.type);
        var type_color = GetNodeTypeColor(node.type);
        draw_set_color(type_color);
        draw_text(text_x, text_y, "[" + type_text + "]");
        
        text_y += 25;
        
        draw_set_color(c_ltgray);
        draw_text_ext(text_x, text_y, node.description, 16, panel_w - 30);
        
        text_y += 90;
        
        if (!node.unlocked) {
            draw_set_color(c_teal);
            draw_text(text_x, text_y, "COST: ");
            
            var can_afford = (_player_souls >= node.cost);
            draw_set_color(can_afford ? c_aqua : c_red);
            draw_text(text_x + 70, text_y, string(node.cost) + " souls");
            
            text_y += 25;
        } else {
            draw_set_color(c_lime);
            draw_text(text_x, text_y, "UNLOCKED");
            text_y += 25;
        }
        
        if (!node.unlocked && !CanUnlockNode(selected_node_id)) {
            draw_set_color(c_red);
            draw_text_ext(text_x, text_y, "Requires connected node", 16, panel_w - 30);
        }
        
        if (node.type == "stat_boost" && variable_struct_exists(node, "max_stacks")) {
            text_y += 25;
            draw_set_color(c_aqua);
            var stacks = node.current_stacks ?? 0;
            draw_text(text_x, text_y, "Stack: " + string(stacks) + "/" + string(node.max_stacks));
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
        
        draw_set_color(c_black);
        draw_rectangle(controls_x - 5, controls_y - 5, controls_x + 300, controls_y + 95, false);
        
        draw_set_alpha(1);
        draw_set_color(c_white);
        
        var line_y = controls_y;
        draw_text(controls_x, line_y, "WASD/Arrows - Navigate"); line_y += 18;
        draw_text(controls_x, line_y, "Q/E - Zoom In/Out"); line_y += 18;
        draw_text(controls_x, line_y, "R - Reset View"); line_y += 18;
        draw_text(controls_x, line_y, "Right Click/Drag - Pan"); line_y += 18;
        draw_text(controls_x, line_y, "Enter/Space - Unlock Node"); line_y += 18;
        
        // Show escape status
        if (global.SaveData.career.tutorial.back_button_unlocked) {
            draw_text(controls_x, line_y, "ESC - Back to Menu");
        } else {
            draw_set_color(c_red);
            draw_text(controls_x, line_y, "ESC - [LOCKED]");
        }
        
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
            case "soul_contract": return "CONTRACT";
            case "utility_unlock": return "UTILITY";
            case "character_unlock": return "CHARACTER";
            case "weapon_unlock": return "WEAPON";
            case "stat_boost": return "STAT";
            case "pregame_mod_unlock": return "MODIFIER";
            case "level_unlock": return "LEVEL";
            case "branch": return "PATH";
            default: return "UNKNOWN";
        }
    }
    
    /// @function GetNodeTypeColor(_type)
    static GetNodeTypeColor = function(_type) {
        switch (_type) {
            case "soul_contract": return c_red;
            case "utility_unlock": return c_fuchsia;
            case "character_unlock": return c_purple;
            case "weapon_unlock": return c_orange;
            case "stat_boost": return c_aqua;
            case "pregame_mod_unlock": return c_lime;
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