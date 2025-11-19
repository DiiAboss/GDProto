enum PreGameMod {
    // Physics Manipulators
    BOUNCY,
    METEOR,
    DASH_STRIKE,
    BIG_WEAPON,
    PINBALL_MODE,
    HEAVY_HITTER,
    FEATHERWEIGHT,
    GRAVITY_WELL,
    ICE_RINK,
    
    // Combat Modifiers
    GLASS_CANNON,
    AUTO_AIM,
    DUAL_WIELD,
    LIFESTEAL,
    RICOCHET,
    BERSERK,
    EXECUTE_BASE,
    EXECUTE_BOSS,
    CRIT_ADDICT,
    MULTI_HIT,
    SHARPSHOOTER,
    
    // Movement & Utility
    TIME_SLOW,
    HOVER_BOOTS,
    TELEPORT,
    SPEED_DEMON,
    MAGNETIC_FIELD,
    CHARGE_DASH,
    
    // Economy & Progression
    SOULS_2X,
    EXP_2X,
    LUCKY,
    RANDOM_MOD,
    STAT_HP,
    STAT_DAMAGE,
    STAT_SPEED,
    INVESTOR,
    COMPOUNDING
}


/// @file scr_PreGameModifiers.gml

global.PreGameModifiers = {
    
    // ==========================================
    // PHYSICS MANIPULATORS
    // ==========================================
    
    bouncy: {
        id: PreGameMod.BOUNCY,
        name: "Bouncy Castle",
        description: "All entities have 50% increased knockback",
        sprite: spr_mod_default,
        knockback_mult: 1.5
    },
    
    meteor: {
        id: PreGameMod.METEOR,
        name: "Meteor Strike",
        description: "Enemies that hit walls at high speed explode",
        sprite: spr_mod_default,
        wall_impact_explosion: true,
        explosion_threshold_speed: 8,
        explosion_damage: 20,
        explosion_radius: 64
    },
    
    dash_strike: {
        id: PreGameMod.DASH_STRIKE,
        name: "Dash Strike",
        description: "Dashing through enemies sends them flying and deals damage",
        sprite: spr_mod_default,
        dash_damage: 15,
        dash_knockback: 10
    },
    
    big_weapon: {
        id: PreGameMod.BIG_WEAPON,
        name: "Heavyweight Champion",
        description: "Weapons are 2x bigger but 1.5x slower",
        sprite: spr_mod_default,
        weapon_size_mult: 2.0,
        attack_speed_mult: 0.67
    },
    
    pinball_mode: {
        id: PreGameMod.PINBALL_MODE,
        name: "Pinball Wizard",
        description: "Enemies bounce off screen edges",
        sprite: spr_mod_default,
        screen_bounce: true,
        bounce_damage: 5
    },
    
    heavy_hitter: {
        id: PreGameMod.HEAVY_HITTER,
        name: "Heavy Hitter",
        description: "Attacks are 30% slower but knock enemies 3x farther",
        sprite: spr_mod_default,
        attack_speed_mult: 0.7,
        knockback_mult: 3.0
    },
    
    featherweight: {
        id: PreGameMod.FEATHERWEIGHT,
        name: "Featherweight",
        description: "Move 25% faster, attacks knock enemies 50% less",
        sprite: spr_mod_default,
        move_speed_mult: 1.25,
        knockback_mult: 0.5
    },
    
    gravity_well: {
        id: PreGameMod.GRAVITY_WELL,
        name: "Gravity Well",
        description: "Killed enemies pull nearby enemies toward death location",
        sprite: spr_mod_default,
        death_pull_radius: 128,
        death_pull_strength: 5
    },
    
    ice_rink: {
        id: PreGameMod.ICE_RINK,
        name: "Ice Rink",
        description: "All entities slide after moving (momentum physics)",
        sprite: spr_mod_default,
        friction_mult: 0.5,
        momentum_enabled: true
    },
    
    // ==========================================
    // COMBAT MODIFIERS
    // ==========================================
    
    glass_cannon: {
        id: PreGameMod.GLASS_CANNON,
        name: "Glass Cannon",
        description: "Deal 2x damage but have 50% HP",
        sprite: spr_mod_default,
        damage_mult: 2.0,
        hp_mult: 0.5
    },
    
    auto_aim: {
        id: PreGameMod.AUTO_AIM,
        name: "Auto Aim",
        description: "Projectiles home toward nearest enemy",
        sprite: spr_mod_default,
        homing_enabled: true,
        homing_strength: 0.15
    },
    
    dual_wield: {
        id: PreGameMod.DUAL_WIELD,
        name: "Dual Wield",
        description: "Secondary weapon activates with right click",
        sprite: spr_mod_default,
        dual_wield_enabled: true
    },
    
    lifesteal: {
        id: PreGameMod.LIFESTEAL,
        name: "Vampiric",
        description: "Heal 1% of damage dealt, drain 0.33 HP/sec",
        sprite: spr_mod_default,
        lifesteal_percent: 0.01,
        hp_drain_per_second: 0.33
    },
    
    ricochet: {
        id: PreGameMod.RICOCHET,
        name: "Ricochet",
        description: "Projectiles bounce off walls and enemies",
        sprite: spr_mod_default,
        projectile_bounces: 3,
        bounce_damage_mult: 0.8
    },
    
    berserk: {
        id: PreGameMod.BERSERK,
        name: "Berserk",
        description: "Start 50% damage. At 1% HP, 3x damage (scales with missing HP)",
        sprite: spr_mod_default,
        base_damage_mult: 0.5,
        max_damage_mult: 3.0
    },
    
    execute_base: {
        id: PreGameMod.EXECUTE_BASE,
        name: "Executioner",
        description: "Instantly kill base enemies below 20% HP",
        sprite: spr_mod_default,
        execute_threshold: 0.20,
        targets: "base"
    },
    
    execute_boss: {
        id: PreGameMod.EXECUTE_BOSS,
        name: "Regicide",
        description: "Instantly kill boss enemies below 20% HP",
        sprite: spr_mod_default,
        execute_threshold: 0.20,
        targets: "boss"
    },
    
    crit_addict: {
        id: PreGameMod.CRIT_ADDICT,
        name: "Crit Addict",
        description: "50% crit chance, normal attacks -30% damage",
        sprite: spr_mod_default,
        crit_chance: 0.5,
        non_crit_damage_mult: 0.7
    },
    
    multi_hit: {
        id: PreGameMod.MULTI_HIT,
        name: "Double Tap",
        description: "Attacks hit twice, 50% damage each",
        sprite: spr_mod_default,
        hit_count: 2,
        damage_per_hit_mult: 0.5
    },
    
    sharpshooter: {
        id: PreGameMod.SHARPSHOOTER,
        name: "Sharpshooter",
        description: "+100% damage to enemies off-screen",
        sprite: spr_mod_default,
        offscreen_damage_mult: 2.0
    },
    
    // ==========================================
    // MOVEMENT & UTILITY
    // ==========================================
    
    time_slow: {
        id: PreGameMod.TIME_SLOW,
        name: "Bullet Time",
        description: "Dash = 5s bullet time (10s cooldown). You move normal speed",
        sprite: spr_mod_default,
        time_scale: 0.3,
        duration: 5,
        cooldown: 10,
        player_time_scale: 1.0
    },
    
    hover_boots: {
        id: PreGameMod.HOVER_BOOTS,
        name: "Hover Boots",
        description: "Float over pits before falling",
        sprite: spr_mod_default,
        hover_duration: 1.5
    },
    
    teleport: {
        id: PreGameMod.TELEPORT,
        name: "Blink",
        description: "Dash = short teleport (no i-frames)",
        sprite: spr_mod_default,
        teleport_enabled: true,
        teleport_distance: 100,
        has_iframes: false
    },
    
    speed_demon: {
        id: PreGameMod.SPEED_DEMON,
        name: "Speed Demon",
        description: "+50% move speed, -50% HP and weight",
        sprite: spr_mod_default,
        move_speed_mult: 1.5,
        hp_mult: 0.5,
        weight_mult: 0.5
    },
    
    magnetic_field: {
        id: PreGameMod.MAGNETIC_FIELD,
        name: "Magnetic Field",
        description: "Pickups pulled from 2x farther",
        sprite: spr_mod_default,
        pickup_radius_mult: 2.0
    },
    
    charge_dash: {
        id: PreGameMod.CHARGE_DASH,
        name: "Charge Dash",
        description: "Hold dash to charge, release to launch",
        sprite: spr_mod_default,
        charge_enabled: true,
        max_charge_time: 2.0,
        max_charge_mult: 3.0
    },
    
    // ==========================================
    // ECONOMY & PROGRESSION
    // ==========================================
    
    souls_2x: {
        id: PreGameMod.SOULS_2X,
        name: "Soul Harvest",
        description: "Earn 2x souls per run",
        sprite: spr_mod_default,
        soul_mult: 2.0
    },
    
    exp_2x: {
        id: PreGameMod.EXP_2X,
        name: "Adrenaline Rush",
        description: "2x EXP, expires after 10 seconds",
        sprite: spr_mod_default,
        exp_mult: 2.0,
        exp_lifetime: 10
    },
    
    lucky: {
        id: PreGameMod.LUCKY,
        name: "Lucky",
        description: "50% increased drop rates",
        sprite: spr_mod_default,
        drop_rate_mult: 1.5
    },
    
    random_mod: {
        id: PreGameMod.RANDOM_MOD,
        name: "Wild Card",
        description: "Start with random in-game mod (Lvl 1-5)",
        sprite: spr_mod_default,
        random_mod_count: 1,
        random_mod_max_level: 5
    },
    
    stat_hp: {
        id: PreGameMod.STAT_HP,
        name: "Vitality Boost",
        description: "+10% Max HP",
        sprite: spr_mod_default,
        hp_mult: 1.1
    },
    
    stat_damage: {
        id: PreGameMod.STAT_DAMAGE,
        name: "Power Boost",
        description: "+10% Damage",
        sprite: spr_mod_default,
        damage_mult: 1.1
    },
    
    stat_speed: {
        id: PreGameMod.STAT_SPEED,
        name: "Agility Boost",
        description: "+10% Move Speed",
        sprite: spr_mod_default,
        move_speed_mult: 1.1
    },
    
    investor: {
        id: PreGameMod.INVESTOR,
        name: "Investor",
        description: "Gold generates 1% interest/sec (max 2x)",
        sprite: spr_mod_default,
        interest_rate: 0.01,
        interest_cap_mult: 2.0
    },
    
    compounding: {
        id: PreGameMod.COMPOUNDING,
        name: "Compounding Interest",
        description: "Each kill +1% soul gain (stacks infinitely)",
        sprite: spr_mod_default,
        soul_gain_per_kill: 0.01
    }
};

// ------------------------------------------
// PRE-GAME META MODIFIERS
// ------------------------------------------

global.Modifiers.Souls2x = {
    name: "Soul Harvest",
    description: "Earn 2x souls per run",
    triggers: [],  // ← NO TRIGGERS! It's a passive stat bonus
    synergy_tags: [],
    
    stats: {
        soul_mult: 2.0
    }
    // No action function needed!
};

global.Modifiers.StatHP = {
    name: "Vitality",
    description: "+10% max HP",
    triggers: [MOD_TRIGGER.PASSIVE],
    synergy_tags: [SYNERGY_TAG.TANKY],
    
    passive_stats: {
        max_hp_mult: 1.10
    },
    
    action: function(_entity, _event) {
        // Applied via CalculateCachedStats
    }
};

global.Modifiers.StatDamage = {
    name: "Power",
    description: "+10% damage",
    triggers: [MOD_TRIGGER.PASSIVE],
    synergy_tags: [SYNERGY_TAG.STRENGTH],
    
    passive_stats: {
        damage_mult: 1.10
    },
    
    action: function(_entity, _event) {
        // Applied via CalculateCachedStats
    }
};

global.Modifiers.StatSpeed = {
    name: "Swiftness",
    description: "+10% movement speed",
    triggers: [MOD_TRIGGER.PASSIVE],
    synergy_tags: [SYNERGY_TAG.SPEED],
    
    passive_stats: {
        speed_mult: 1.10
    },
    
    action: function(_entity, _event) {
        // Applied via CalculateCachedStats
    }
};

global.Modifiers.Bouncy = {
    name: "Bouncy Castle",
    description: "Projectiles bounce off walls",
    triggers: [MOD_TRIGGER.ON_ATTACK],
    synergy_tags: [SYNERGY_TAG.BOUNCING],
    
    action: function(_entity, _event) {
        if (_event.projectile != noone && instance_exists(_event.projectile)) {
            _event.projectile.bouncy = true;
            _event.projectile.bounce_count = 3;
        }
    }
};

global.Modifiers.MeteorStrike = {
    name: "Meteor Strike",
    description: "Projectiles call down meteors on impact",
    triggers: [MOD_TRIGGER.ON_HIT],
    synergy_tags: [SYNERGY_TAG.EXPLOSIVE, SYNERGY_TAG.FIRE],
    
    proc_chance: 0.20,
    meteor_damage: 50,
    meteor_radius: 80,
    
    action: function(_entity, _event) {
        var mod_template = global.Modifiers[$ _event.mod_instance.template_key];
        
        if (random(1) > mod_template.proc_chance) return;
        
        // Spawn meteor at hit location
        if (variable_struct_exists(_event, "target") && instance_exists(_event.target)) {
            var meteor = instance_create_depth(
                _event.target.x, 
                _event.target.y - 200, 
                -100, 
                obj_meteor // You'll need to create this object
            );
            meteor.owner = _entity;
            meteor.damage = mod_template.meteor_damage;
            meteor.explosion_radius = mod_template.meteor_radius;
        }
    }
};