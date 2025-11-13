
// TAG-BASED SYNERGY SYSTEM

// This system allows dynamic interactions between:
// - Character Classes (innate tags)
// - Weapons (innate tags)
// - Active Modifiers (temporary tags)
//
// Tags are checked at RUNTIME to determine behavior
// No hardcoded synergies - everything is emergent


// TAG DEFINITIONS

enum SYNERGY_TAG {
    // Character Identity Tags
    VAMPIRE,
    HOLY,
    BRUTAL,
    ATHLETIC,
    ROGUE,
    MAGE,
    
    // Weapon Type Tags
    MELEE,
    RANGED,
    EXPLOSIVE,
    THROWABLE,
    PIERCING,
    BLUNT,
    
    // Elemental Tags
    FIRE,
    ICE,
    LIGHTNING,
    POISON,
    
    // Behavior Tags
    LIFESTEAL,
    CHAIN,
    SPLASH,
    BOUNCING,
    HOMING,
    PIERCING_SHOT,
    
    // NEW: Stat Modifier Tags
    STRENGTH,      // Increases damage
    SPEED,         // Increases movement/attack speed
    WEIGHT,        // Increases knockback/throw distance
    CRITICAL,      // Critical hit chance/damage
    REGENERATION,  // Health regen
    GLASS_CANNON,  // High damage, low defense
    TANKY,         // High defense, slower
    
    // Synergy Result Tags
    BURNING_LIFESTEAL,
    HOLY_EXPLOSION,
    FASTBALL,
    BLOOD_TRAIL,
    FROZEN_EXPLOSION,
    STEAM_CLOUD,
    HOMING_THROW,
    POWER_THROW
}


// SYNERGY TAG CONTAINER

/// @function SynergyTags()
/// @description Container for all active tags on an entity
function SynergyTags() constructor {
    tags = [];
    tag_sources = {}; // Track where each tag came from
    
    /// @function AddTag(_tag, _source)
    static AddTag = function(_tag, _source = "unknown") {
        if (!HasTag(_tag)) {
            array_push(tags, _tag);
            tag_sources[$ string(_tag)] = _source;
        }
    }
    
    /// @function RemoveTag(_tag)
    static RemoveTag = function(_tag) {
        var index = array_get_index(tags, _tag);
        if (index != -1) {
            array_delete(tags, index, 1);
            variable_struct_remove(tag_sources, string(_tag));
        }
    }
    
    /// @function HasTag(_tag)
    static HasTag = function(_tag) {
        return array_contains(tags, _tag);
    }
    
    /// @function HasAllTags(_tag_array)
    static HasAllTags = function(_tag_array) {
        for (var i = 0; i < array_length(_tag_array); i++) {
            if (!HasTag(_tag_array[i])) return false;
        }
        return true;
    }
    
    /// @function HasAnyTag(_tag_array)
    static HasAnyTag = function(_tag_array) {
        for (var i = 0; i < array_length(_tag_array); i++) {
            if (HasTag(_tag_array[i])) return true;
        }
        return false;
    }
    
    /// @function GetAllTags()
    static GetAllTags = function() {
        return tags;
    }
    
    /// @function Clear()
    static Clear = function() {
        tags = [];
        tag_sources = {};
    }
    
    /// @function DebugPrint()
    static DebugPrint = function() {
        var tag_names = "";
        for (var i = 0; i < array_length(tags); i++) {
            tag_names += string(tags[i]);
            if (i < array_length(tags) - 1) tag_names += ", ";
        }
        return tag_names;
    }
}


// CHARACTER CLASS TAG INITIALIZATION

/// @function InitializeCharacterTags(_class_type)
/// @description Returns innate tags for a character class
function InitializeCharacterTags(_class_type) {
    var tags = new SynergyTags();
    
    switch (_class_type) {
        case CharacterClass.WARRIOR:
            tags.AddTag(SYNERGY_TAG.BRUTAL, "class_innate");
            tags.AddTag(SYNERGY_TAG.MELEE, "class_innate");
            break;
            
        case CharacterClass.HOLY_MAGE:
            tags.AddTag(SYNERGY_TAG.HOLY, "class_innate");
            tags.AddTag(SYNERGY_TAG.RANGED, "class_innate");
            tags.AddTag(SYNERGY_TAG.MAGE, "class_innate");  // NEW
            break;
            
        case CharacterClass.VAMPIRE:
            tags.AddTag(SYNERGY_TAG.VAMPIRE, "class_innate");
            tags.AddTag(SYNERGY_TAG.LIFESTEAL, "class_innate");
            break;
            
        case CharacterClass.BASEBALL_PLAYER:  // NEW (for future)
            tags.AddTag(SYNERGY_TAG.ATHLETIC, "class_innate");
            tags.AddTag(SYNERGY_TAG.MELEE, "class_innate");
            break;
    }
    
    return tags;
}


// WEAPON TAG INITIALIZATION

/// @function InitializeWeaponTags(_weapon_id)
/// @description Returns innate tags for a weapon type
function InitializeWeaponTags(_weapon_id) {
    var tags = new SynergyTags();
    
    switch (_weapon_id) {
        case Weapon.Sword:
            tags.AddTag(SYNERGY_TAG.MELEE, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.PIERCING, "weapon_innate");
            break;
            
        case Weapon.BaseballBat:
            tags.AddTag(SYNERGY_TAG.MELEE, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.BLUNT, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.ATHLETIC, "weapon_innate");
            break;
            
        case Weapon.Dagger:
            tags.AddTag(SYNERGY_TAG.MELEE, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.PIERCING, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.ROGUE, "weapon_innate");
            break;
            
        case Weapon.Holy_Water:
            tags.AddTag(SYNERGY_TAG.THROWABLE, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.EXPLOSIVE, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.HOLY, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.SPLASH, "weapon_innate");
            break;
            
        case Weapon.Bow:
            tags.AddTag(SYNERGY_TAG.RANGED, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.PIERCING, "weapon_innate");
            break;
            
        case Weapon.ChargeCannon:
            tags.AddTag(SYNERGY_TAG.RANGED, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.EXPLOSIVE, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.BLUNT, "weapon_innate");
            break;
            
        case Weapon.Boomerang:
            tags.AddTag(SYNERGY_TAG.RANGED, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.THROWABLE, "weapon_innate");
            tags.AddTag(SYNERGY_TAG.BOUNCING, "weapon_innate");
            break;
		case Weapon.ThrowableItem:
		    tags.AddTag(SYNERGY_TAG.THROWABLE, "weapon_innate");
		    break;
    }
    
    return tags;
}


// COMBINED TAG RESOLUTION

/// @function GetCombinedTags(_player, _weapon_struct)
/// @description Merges character tags + weapon tags + active mod tags
function GetCombinedTags(_player, _weapon_struct) {
    var combined = new SynergyTags();
    
    // Add character innate tags
    if (variable_instance_exists(_player, "synergy_tags")) {
        var player_tags = _player.synergy_tags.GetAllTags();
        for (var i = 0; i < array_length(player_tags); i++) {
            combined.AddTag(player_tags[i], "character");
        }
    }
    
    // Add weapon innate tags
    if (variable_struct_exists(_weapon_struct, "synergy_tags")) {
        var weapon_tags = _weapon_struct.synergy_tags.GetAllTags();
        for (var i = 0; i < array_length(weapon_tags); i++) {
            combined.AddTag(weapon_tags[i], "weapon");
        }
    }
    
    // Add active modifier tags
    if (variable_instance_exists(_player, "mod_list")) {
        for (var i = 0; i < array_length(_player.mod_list); i++) {
            var mod_instance = _player.mod_list[i];
            var mod_template = global.Modifiers[$ mod_instance.template_key];
            
            if (variable_struct_exists(mod_template, "synergy_tags")) {
                var mod_tags = mod_template.synergy_tags;
                for (var j = 0; j < array_length(mod_tags); j++) {
                    combined.AddTag(mod_tags[j], "modifier:" + mod_instance.template_key);
                }
            }
        }
    }
    
    return combined;
}


// SYNERGY DETECTION & RESOLUTION

/// @function DetectSynergies(_combined_tags)
/// @description Checks for emergent synergy combinations
function DetectSynergies(_combined_tags) {
    var detected = [];
    
    // Vampire + Explosive = Lifesteal Explosion
    if (_combined_tags.HasAllTags([SYNERGY_TAG.VAMPIRE, SYNERGY_TAG.EXPLOSIVE])) {
        array_push(detected, SYNERGY_TAG.BURNING_LIFESTEAL);
    }
    
    // Holy + Explosive = Enhanced Holy Damage
    if (_combined_tags.HasAllTags([SYNERGY_TAG.HOLY, SYNERGY_TAG.EXPLOSIVE])) {
        array_push(detected, SYNERGY_TAG.HOLY_EXPLOSION);
    }
    
    // Athletic + Throwable = Fastball
    if (_combined_tags.HasAllTags([SYNERGY_TAG.ATHLETIC, SYNERGY_TAG.THROWABLE])) {
        array_push(detected, SYNERGY_TAG.FASTBALL);
    }
    
    // Vampire + Melee = Blood Trail
    if (_combined_tags.HasAllTags([SYNERGY_TAG.VAMPIRE, SYNERGY_TAG.MELEE])) {
        array_push(detected, SYNERGY_TAG.BLOOD_TRAIL);
    }
    
    // Fire + Ice = Steam Cloud
    if (_combined_tags.HasAllTags([SYNERGY_TAG.FIRE, SYNERGY_TAG.ICE])) {
        array_push(detected, SYNERGY_TAG.STEAM_CLOUD);
    }
    
    // Fire + Explosive = Burning Explosion
    if (_combined_tags.HasAllTags([SYNERGY_TAG.FIRE, SYNERGY_TAG.EXPLOSIVE])) {
        array_push(detected, SYNERGY_TAG.BURNING_LIFESTEAL); // Reuse or create new
    }
    
    // Ice + Explosive = Frozen Explosion (slows enemies)
    if (_combined_tags.HasAllTags([SYNERGY_TAG.ICE, SYNERGY_TAG.EXPLOSIVE])) {
        array_push(detected, SYNERGY_TAG.FROZEN_EXPLOSION);
    }
    
    // Lightning + Splash = Chain Lightning Splash
    if (_combined_tags.HasAllTags([SYNERGY_TAG.LIGHTNING, SYNERGY_TAG.SPLASH])) {
        array_push(detected, SYNERGY_TAG.CHAIN);
    }
	
	// NEW: Mage + Throwable = Homing Throw
    if (_combined_tags.HasAllTags([SYNERGY_TAG.MAGE, SYNERGY_TAG.THROWABLE])) {
        array_push(detected, SYNERGY_TAG.HOMING_THROW);
    }
    
    // NEW: Athletic + Throwable = Power Throw
    if (_combined_tags.HasAllTags([SYNERGY_TAG.ATHLETIC, SYNERGY_TAG.THROWABLE])) {
        array_push(detected, SYNERGY_TAG.POWER_THROW);
    }
    
    return detected;
}


// SYNERGY APPLICATION

/// @function ApplySynergyBehavior(_projectile, _combined_tags, _detected_synergies, _player)
/// @description Modifies projectile behavior based on active synergies
function ApplySynergyBehavior(_projectile, _combined_tags, _detected_synergies, _player) {
    if (!instance_exists(_projectile)) return;
    
    // Store tags on projectile for reference
    _projectile.synergy_tags = _combined_tags;
    _projectile.active_synergies = _detected_synergies;
    _projectile.synergy_owner = _player;
    
    // Apply modifier-based elemental damage
    if (_combined_tags.HasTag(SYNERGY_TAG.FIRE)) {
        _projectile.element_type = ELEMENT.FIRE;
        _projectile.burn_chance = 0.5;
    }
    
    if (_combined_tags.HasTag(SYNERGY_TAG.ICE)) {
        _projectile.element_type = ELEMENT.ICE;
        _projectile.freeze_chance = 0.5;
    }
    
    if (_combined_tags.HasTag(SYNERGY_TAG.LIGHTNING)) {
        _projectile.element_type = ELEMENT.LIGHTNING;
        _projectile.shock_chance = 0.5;
    }
    
    if (_combined_tags.HasTag(SYNERGY_TAG.POISON)) {
        _projectile.element_type = ELEMENT.POISON;
        _projectile.poison_chance = 0.5;
    }
    
    // Apply synergy-specific behaviors
    for (var i = 0; i < array_length(_detected_synergies); i++) {
        var synergy = _detected_synergies[i];
        
        switch (synergy) {
            case SYNERGY_TAG.FASTBALL:
                // Baseball player throws faster
                _projectile.speed *= 2.0;
                _projectile.targetDistance *= 1.5;
                break;
                
            case SYNERGY_TAG.HOLY_EXPLOSION:
                // Holy explosions deal more damage
                if (variable_instance_exists(_projectile, "explosion_damage")) {
                    _projectile.explosion_damage *= 1.5;
                }
                if (variable_instance_exists(_projectile, "explosion_radius")) {
                    _projectile.explosion_radius *= 1.3;
                }
                break;
                
            case SYNERGY_TAG.BURNING_LIFESTEAL:
                // Vampire explosive with lifesteal
                _projectile.has_lifesteal = true;
                _projectile.lifesteal_percent = 0.15;
                break;
                
            case SYNERGY_TAG.BLOOD_TRAIL:
                // Vampire melee spawns blood projectiles
                _projectile.spawn_blood_on_hit = true;
                break;
                
            case SYNERGY_TAG.FROZEN_EXPLOSION:
                // Ice explosion slows enemies
                _projectile.freeze_on_explosion = true;
                _projectile.freeze_duration = 120;
                break;
                
            case SYNERGY_TAG.STEAM_CLOUD:
                // Fire + Ice creates lingering steam cloud
                _projectile.create_steam_cloud = true;
                break;
            
            case SYNERGY_TAG.HOMING_THROW:
		    // Mage homing throw - VERY STRONG
		    _projectile.is_homing = true;
		    _projectile.homing_strength = 0.25;  // Increased from 0.15
		    _projectile.homing_target = instance_nearest(_projectile.x, _projectile.y, obj_enemy);
		    _projectile.visual_effect = "purple_glow";
		    break;
                
            case SYNERGY_TAG.POWER_THROW:
                // Baseball player power throw
                _projectile.speed *= 1.1;  // 2x throw speed
                _projectile.damage *= 1.5;  // 1.5x damage
                if (variable_instance_exists(_projectile, "targetDistance")) {
                    _projectile.targetDistance *= 1;  // Goes further
                }
                _projectile.visual_effect = "speed_lines";  // Visual indicator
                break;
 
        }
    }
}


// EXPLOSION SYNERGY HANDLER

/// @function ApplyExplosionSynergies(_explosion_x, _explosion_y, _owner, _combined_tags, _detected_synergies)
/// @description Handles synergies that affect explosion behavior
function ApplyExplosionSynergies(_explosion_x, _explosion_y, _owner, _combined_tags, _detected_synergies, _base_damage, _base_radius) {
    var damage_mult = 1.0;
    var radius_mult = 1.0;
    var should_lifesteal = false;
    var lifesteal_amount = 0;
    var element = ELEMENT.PHYSICAL;
    var status_effect = noone;
    
    // Check for detected synergies
    for (var i = 0; i < array_length(_detected_synergies); i++) {
        var synergy = _detected_synergies[i];
        
        switch (synergy) {
            case SYNERGY_TAG.HOLY_EXPLOSION:
                damage_mult *= 1.5;
                radius_mult *= 1.3;
                element = ELEMENT.FIRE; // Holy explosions burn
                break;
                
            case SYNERGY_TAG.BURNING_LIFESTEAL:
                should_lifesteal = true;
                lifesteal_amount = 0.15;
                element = ELEMENT.FIRE;
                break;
                
            case SYNERGY_TAG.FROZEN_EXPLOSION:
                element = ELEMENT.ICE;
                status_effect = {
                    type: ELEMENT.ICE,
                    duration: 120,
                    slow_mult: 0.5
                };
                break;
        }
    }
    
    // Check for raw elemental tags (from mods)
    if (_combined_tags.HasTag(SYNERGY_TAG.FIRE) && element == ELEMENT.PHYSICAL) {
        element = ELEMENT.FIRE;
    }
    if (_combined_tags.HasTag(SYNERGY_TAG.ICE) && element == ELEMENT.PHYSICAL) {
        element = ELEMENT.ICE;
    }
    if (_combined_tags.HasTag(SYNERGY_TAG.LIGHTNING) && element == ELEMENT.PHYSICAL) {
        element = ELEMENT.LIGHTNING;
    }
    if (_combined_tags.HasTag(SYNERGY_TAG.POISON) && element == ELEMENT.PHYSICAL) {
        element = ELEMENT.POISON;
    }
    
    // Apply damage to enemies in radius
    var final_damage = _base_damage * damage_mult;
    var final_radius = _base_radius * radius_mult;
    var total_lifesteal_heal = 0;
    
    with (obj_enemy) {
        var dist = point_distance(x, y, _explosion_x, _explosion_y);
        
        if (dist <= final_radius && !marked_for_death) {
            // Calculate falloff damage
            var falloff = 1 - (dist / final_radius) * 0.75; // 25% at edge
            var actual_damage = final_damage * falloff;
            
            // Apply damage with element
            if (variable_instance_exists(id, "damage_sys")) {
                damage_sys.TakeDamage(actual_damage, _owner, element);
            }
            
            // Apply status effect if present
            if (status_effect != noone && variable_instance_exists(id, "status")) {
                status.ApplyStatusEffect(status_effect.type, status_effect);
            }
            
            // Track lifesteal
            if (should_lifesteal) {
                total_lifesteal_heal += actual_damage * lifesteal_amount;
            }
        }
    }
    
    // Apply lifesteal healing
    if (should_lifesteal && instance_exists(_owner) && total_lifesteal_heal > 0) {
        _owner.hp = min(_owner.hp + total_lifesteal_heal, _owner.hp_max);
        
        // Visual feedback
        spawn_damage_number(_owner.x, _owner.y - 32, floor(total_lifesteal_heal), c_red, false);
    }
    
    // Create visual effect based on element
    CreateExplosionVisuals(_explosion_x, _explosion_y, final_radius, element);
}


// VISUAL EFFECTS

/// @function CreateExplosionVisuals(_x, _y, _radius, _element)
function CreateExplosionVisuals(_x, _y, _radius, _element) {
    var color1 = c_white;
    var color2 = c_gray;
    var particle_count = 20;
    
    switch (_element) {
        case ELEMENT.FIRE:
            color1 = c_red;
            color2 = c_orange;
            break;
        case ELEMENT.ICE:
            color1 = c_aqua;
            color2 = c_blue;
            break;
        case ELEMENT.LIGHTNING:
            color1 = c_yellow;
            color2 = c_white;
            particle_count = 30;
            break;
        case ELEMENT.POISON:
            color1 = make_color_rgb(100, 255, 100);
            color2 = make_color_rgb(50, 200, 50);
            break;
    }
    
    // Spawn particles
    repeat(particle_count) {
        var p = instance_create_depth(_x, _y, -9999, obj_particle);
        p.direction = random(360);
        p.speed = random_range(3, 8);
        p.image_blend = choose(color1, color2);
        p.image_alpha = random_range(0.6, 1.0);
    }
}


// HELPER FUNCTIONS

/// @function UpdateWeaponTags(_player, _weapon_index)
/// @description Called when player switches weapons
function UpdateWeaponTags(_player, _weapon_index) {
    if (!instance_exists(_player)) return;
    if (!variable_instance_exists(_player, "weapons")) return;
    
    var weapon_struct = _player.weapons[_weapon_index];
    if (weapon_struct == noone) return;
    
    // Initialize weapon tags if not present
    if (!variable_struct_exists(weapon_struct, "synergy_tags")) {
        weapon_struct.synergy_tags = InitializeWeaponTags(weapon_struct.id);
    }
    
    // Update combined tags for quick access
    _player.active_combined_tags = GetCombinedTags(_player, weapon_struct);
    _player.active_synergies = DetectSynergies(_player.active_combined_tags);
}

/// @function AddModifierTag(_player, _tag)
/// @description Helper to add a tag from a modifier
function AddModifierTag(_player, _tag) {
    if (!instance_exists(_player)) return;
    
    if (!variable_instance_exists(_player, "active_mod_tags")) {
        _player.active_mod_tags = new SynergyTags();
    }
    
    _player.active_mod_tags.AddTag(_tag, "modifier_runtime");
    
    // Recalculate combined tags
    if (variable_instance_exists(_player, "weapons") && 
        variable_instance_exists(_player, "current_weapon_index")) {
        UpdateWeaponTags(_player, _player.current_weapon_index);
    }
}

/// @function RemoveModifierTag(_player, _tag)
/// @description Helper to remove a tag when modifier expires
function RemoveModifierTag(_player, _tag) {
    if (!instance_exists(_player)) return;
    if (!variable_instance_exists(_player, "active_mod_tags")) return;
    
    _player.active_mod_tags.RemoveTag(_tag);
    
    // Recalculate combined tags
    if (variable_instance_exists(_player, "weapons") && 
        variable_instance_exists(_player, "current_weapon_index")) {
        UpdateWeaponTags(_player, _player.current_weapon_index);
    }
}


/// @function GetTagName(_tag_enum)
/// @description Returns readable name for a tag enum
function GetTagName(_tag_enum) {
    switch (_tag_enum) {
        // Character Identity
        case SYNERGY_TAG.VAMPIRE: return "VAMPIRE";
        case SYNERGY_TAG.HOLY: return "HOLY";
        case SYNERGY_TAG.BRUTAL: return "BRUTAL";
        case SYNERGY_TAG.ATHLETIC: return "ATHLETIC";
        case SYNERGY_TAG.ROGUE: return "ROGUE";
        
        // Weapon Type
        case SYNERGY_TAG.MELEE: return "MELEE";
        case SYNERGY_TAG.RANGED: return "RANGED";
        case SYNERGY_TAG.EXPLOSIVE: return "EXPLOSIVE";
        case SYNERGY_TAG.THROWABLE: return "THROWABLE";
        case SYNERGY_TAG.PIERCING: return "PIERCING";
        case SYNERGY_TAG.BLUNT: return "BLUNT";
        
        // Elements
        case SYNERGY_TAG.FIRE: return "FIRE";
        case SYNERGY_TAG.ICE: return "ICE";
        case SYNERGY_TAG.LIGHTNING: return "LIGHTNING";
        case SYNERGY_TAG.POISON: return "POISON";
        
        // Behaviors
        case SYNERGY_TAG.LIFESTEAL: return "LIFESTEAL";
        case SYNERGY_TAG.CHAIN: return "CHAIN";
        case SYNERGY_TAG.SPLASH: return "SPLASH";
        case SYNERGY_TAG.BOUNCING: return "BOUNCING";
        case SYNERGY_TAG.HOMING: return "HOMING";
        case SYNERGY_TAG.PIERCING_SHOT: return "PIERCING_SHOT";
        
        // Synergy Results
        case SYNERGY_TAG.BURNING_LIFESTEAL: return "BURNING_LIFESTEAL";
        case SYNERGY_TAG.HOLY_EXPLOSION: return "HOLY_EXPLOSION";
        case SYNERGY_TAG.FASTBALL: return "FASTBALL";
        case SYNERGY_TAG.BLOOD_TRAIL: return "BLOOD_TRAIL";
        case SYNERGY_TAG.FROZEN_EXPLOSION: return "FROZEN_EXPLOSION";
        case SYNERGY_TAG.STEAM_CLOUD: return "STEAM_CLOUD";
		
		case SYNERGY_TAG.STRENGTH: return "STRENGTH";
case SYNERGY_TAG.SPEED: return "SPEED";
case SYNERGY_TAG.WEIGHT: return "WEIGHT";
case SYNERGY_TAG.CRITICAL: return "CRITICAL";
case SYNERGY_TAG.REGENERATION: return "REGENERATION";
case SYNERGY_TAG.GLASS_CANNON: return "GLASS_CANNON";
case SYNERGY_TAG.TANKY: return "TANKY";
        
        default: return "UNKNOWN_TAG_" + string(_tag_enum);
    }
}