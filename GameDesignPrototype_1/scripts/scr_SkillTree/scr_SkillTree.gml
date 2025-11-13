global.SkillTree = {
    // ROOT NODE (Always owned)
    root: {
        id: "root",
        type: "character_unlock",
        name: "Warrior",
        description: "The first hero. Your journey begins here.",
        character: CharacterClass.WARRIOR,
        cost: 0,
        unlocked: true, // Always true
        position: {x: 400, y: 300},
        connections: ["combat_path", "defense_path", "utility_path"],
        sprite: spr_vh_walk_south
    },
    
    // BRANCH NODES (Organizational)
    combat_path: {
        id: "combat_path",
        type: "branch",
        name: "Path of Combat",
        description: "Master the art of dealing damage",
        cost: 0,
        unlocked: false,
        position: {x: 300, y: 200},
        connections: ["root", "sword_unlock", "bat_unlock"],
        sprite: spr_mod_default
    },
    
    // WEAPON UNLOCKS
    sword_unlock: {
        id: "sword_unlock",
        type: "weapon_unlock",
        name: "Unlock: Sword",
        description: "A reliable blade for close combat",
        weapon: Weapon.Sword,
        cost: 100,
        unlocked: false,
        position: {x: 200, y: 150},
        connections: ["combat_path", "holy_mage_unlock"],
        sprite: spr_sword
    },
    
    bat_unlock: {
        id: "bat_unlock",
        type: "weapon_unlock",
        name: "Unlock: Baseball Bat",
        description: "Swing for the fences",
        weapon: Weapon.BaseballBat,
        cost: 150,
        unlocked: false,
        position: {x: 300, y: 100},
        connections: ["combat_path", "baseball_player_unlock"],
        sprite: spr_way_better_bat
    },
    
    // CHARACTER UNLOCKS
    holy_mage_unlock: {
        id: "holy_mage_unlock",
        type: "character_unlock",
        name: "Unlock: Holy Mage",
        description: "Master of projectiles and area control",
        character: CharacterClass.HOLY_MAGE,
        cost: 500,
        unlocked: false,
        position: {x: 100, y: 100},
        connections: ["sword_unlock", "magic_mastery"],
        sprite: spr_vh_walk_south // Replace with Holy Mage sprite
    },
    
    baseball_player_unlock: {
        id: "baseball_player_unlock",
        type: "character_unlock",
        name: "Unlock: Baseball Player",
        description: "Homerun hitter with powerful swings",
        character: CharacterClass.BASEBALL_PLAYER,
        cost: 1000,
        unlocked: false,
        position: {x: 300, y: 50},
        connections: ["bat_unlock", "homerun_mastery"],
        sprite: spr_vh_walk_south // Replace with Baseball sprite
    },
    
    vampire_unlock: {
        id: "vampire_unlock",
        type: "character_unlock",
        name: "Unlock: Vampire",
        description: "High mobility and lifesteal specialist",
        character: CharacterClass.VAMPIRE,
        cost: 750,
        unlocked: false,
        position: {x: 600, y: 200},
        connections: ["defense_path", "lifesteal_mastery"],
        sprite: spr_vh_walk_south // Replace with Vampire sprite
    },
    
    // STAT BOOSTS
    hp_boost_1: {
        id: "hp_boost_1",
        type: "stat_boost",
        name: "+10 Max HP",
        description: "Increases maximum health by 10",
        stat: "hp",
        bonus: 10,
        cost: 50,
        max_stacks: 5,
        current_stacks: 0,
        unlocked: false,
        position: {x: 500, y: 200},
        connections: ["defense_path"],
        sprite: spr_mod_default
    },
    
    attack_boost_1: {
        id: "attack_boost_1",
        type: "stat_boost",
        name: "+5% Attack",
        description: "Increases damage by 5%",
        stat: "attack",
        bonus: 0.05, // 5%
        cost: 75,
        max_stacks: 3,
        current_stacks: 0,
        unlocked: false,
        position: {x: 250, y: 150},
        connections: ["combat_path"],
        sprite: spr_mod_default
    },
    
    // MOD UNLOCKS
    triple_shot_unlock: {
        id: "triple_shot_unlock",
        type: "mod_unlock",
        name: "Unlock: Triple Shot",
        description: "Fire 3 projectiles instead of 1",
        mod_key: "TripleShot",
        cost: 400,
        unlocked: false,
        position: {x: 150, y: 200},
        connections: ["holy_mage_unlock", "projectile_mastery"],
        sprite: spr_mod_TripleRhythmFire
    },
    
    // LEVEL UNLOCKS
    arena_2_unlock: {
        id: "arena_2_unlock",
        type: "level_unlock",
        name: "Unlock: Cursed Catacombs",
        description: "A harder arena with better rewards",
        level_id: "arena_2",
        cost: 1000,
        unlocked: false,
        position: {x: 400, y: 500},
        connections: ["combat_path", "defense_path"],
        sprite: spr_mod_default
    }
};








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