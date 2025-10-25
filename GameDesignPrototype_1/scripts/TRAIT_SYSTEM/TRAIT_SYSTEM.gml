// ===== EXPANDED TRAIT SYSTEM =====
// Module role: separates authoring (traits) from runtime weapon behavior.
// Flow overview:
//  - CharacterTraits: per‑actor sliders (body, style, affinities, resources) +
//    a handling metric used by weapons.
//  - WeaponTraits: static authoring for each weapon archetype (mass, range,
//    base stats, combo scaffolding, affinity hooks, transformation thresholds).
//  - WeaponModificationSystem: 3 tiers that convert (character, weapon) into
//    concrete stats/behaviors + optional transformation label. Call
//    getFullModifications() at equip/attack begin; then applyToInstance().
// Notes: 

function CharacterTraits(_id) constructor {
    id = _id;
    
    // Physical (affects weapon handling)
    strength = 5;       // 0-10: Raw power → carries/hefts heavier weapons
    weight = 5;         // 0-10: Body mass → passive recoil sink
    size = 5;           // 0-10: Physical size → leverage/reach convenience
    balance = 5;        // 0-10: Stability → converts recoil into control
    
    // Combat Style (affects attack patterns)
    technique = 5;      // 0-10: Form/precision → structured patterns unlock
    rhythm = 5;         // 0-10: Tempo preference → multiplicative atk speed
    brutality = 5;      // 0-10: Bias toward heavy hits in combos
    finesse = 5;        // 0-10: Bias toward light chains/openers
    
    // Affinities (0-10 each) — multiplied with weapon compatibility later
    affinities = {
        holy: 0,
        chaos: 0,
        nature: 0,
        tech: 0,
        shadow: 0
    };
    
    // Special Resources (what they can throw/shoot) — drives projectile mods
    resourceType = "none";     // "daggers", "holy_water", "bombs", etc
    resourceCount = 0;
    resourceRegen = 0;          // Per second; external system should tick
    
    // Derived calculations
    // Handling: single scalar used across mods to gate speed/damage/recoil.
    // Higher values mean the character makes the weapon feel lighter.
    getHandlingRating = function(_weaponWeight) {
        // How well can they handle this weapon weight?
        var strengthRatio = strength / max(1, _weaponWeight); // prevent div0
        var sizeBonus = size * 0.1; // Bigger = better leverage
        var balanceBonus = balance * 0.1; // Stability aids control
        return strengthRatio + sizeBonus + balanceBonus; // ~0.0..3.0 typical
    }
}

function WeaponTraits(_id) constructor {
    id = _id;
    weaponObject = obj_sword;  // Default spawn object for this weapon archetype
    
    // Physical properties — paired with CharacterTraits for handling
    weightClass = 5;        // 0-10: How heavy (feeds handling)
    lengthClass = 5;        // 0-10: How long/unwieldy (future aim tax)
    minStrength = 0;        // Absolute minimum to lift (validate elsewhere)
    optimalStrength = 5;    // Where performance peaks (design hint)
    
    // Base stats — Tier 1 starts from these
    baseDamage = 10;
    baseKnockback = 10;
    baseRecoil = 0;
    baseRange = 32;
    
    // Combo structure — Tier 2 may mutate/extend this pattern
    baseComboPattern = ["light", "light", "heavy"];
    maxComboLength = 3;
    allowComboMods = true;       // Can character traits alter sequencing?
    allowProjectileMod = false;  // Allow resource‑based projectile swaps?
    
    // Transformation thresholds — Tier 3 uses handling against these bands
    transformations = {
        tooHeavy: 0.3,      // Below → dragging/struggle moveset
        tooLight: 2.5,      // Above → flourish/one‑handed antics
        perfect: 1.0        // Near → awakened potential if affinity matches
    };
    
    // Affinity compatibility — multiplied with character affinities
    affinityCompatibility = {
        holy: 0,
        chaos: 0,
        nature: 0,
        tech: 0,
        shadow: 0
    };
}

// ===== THREE-TIER MODIFICATION SYSTEM =====
// Tier intent:
//  1) Numeric scaling: universal, fast, always applies.
//  2) Behavioral shaping: conditional tweaks to combos/projectiles/effects.
//  3) Transformations: extreme matches/mismatches swap the entire feel.

function WeaponModificationSystem() constructor {
    
    // TIER 1: Always happens - basic stat scaling
    // Converts raw stats + handling into practical numbers for this pairing.
    applyTier1Mods = function(_weapon, _character) {
        var mods = {
            damage: _weapon.baseDamage,
            knockback: _weapon.baseKnockback,
            attackSpeed: 1.0,
            recoil: _weapon.baseRecoil,
            range: _weapon.baseRange
        };
        
        // Handling affects everything: too heavy → slower/weaker + more recoil,
        // too light → faster but less impact. Middle band scales smoothly.
        var handling = _character.getHandlingRating(_weapon.weightClass);
        
        if (handling < 0.5) {
            // Too heavy!
            mods.damage *= 0.7;
            mods.attackSpeed *= 0.5;
            mods.recoil *= 2;
        } else if (handling < 1.0) {
            // Manageable but not ideal
            mods.damage *= (0.7 + handling * 0.3);
            mods.attackSpeed *= (0.5 + handling * 0.5);
        } else if (handling > 2.0) {
            // Very light for them
            mods.attackSpeed *= 1.5;
            mods.damage *= 0.9; // Less impact on hit
        }
        
        // Rhythm biases tempo across the board (0..10 → x0.5..x1.5)
        mods.attackSpeed *= (0.5 + _character.rhythm / 10);
        
        // Balance + body mass cancel recoil; never below zero
        var recoilReduction = _character.balance * 2 + _character.weight * 1.5;
        mods.recoil = max(0, mods.recoil - recoilReduction);
        
        return mods;
    };
    
    // TIER 2: Conditional - behavior modifications
    // Mutates combo pattern, projectile type, and attaches effect tags.
    applyTier2Mods = function(_weapon, _character, _tier1Mods) {
        var mods = {
            comboPattern: _weapon.baseComboPattern,
            projectileType: "default",
            specialFinisher: "none",
            attackEffects: []
        };
        
        // === COMBO MODIFICATIONS ===
        if (_weapon.allowComboMods) {
            // Finesse front‑loads lights; rogues may end with a throw
            if (_character.finesse > 7) {
                array_insert(mods.comboPattern, 0, "light");
                if (_character.resourceType == "daggers") {
                    mods.specialFinisher = "dagger_throw";
                }
            }
            
            // Brutality appends heavies; big bodies unlock a slam finisher
            if (_character.brutality > 7) {
                array_push(mods.comboPattern, "heavy");
                if (_character.size > 7) {
                    mods.specialFinisher = "ground_slam";
                }
            }
            
            // High technique enforces an alternating precision cadence
            if (_character.technique > 7) {
                mods.comboPattern = ["light", "heavy", "light", "heavy"];
                mods.specialFinisher = "precision_strike";
            }
        }
        
        // === PROJECTILE MODIFICATIONS ===
        // Character resources can retheme a weapon’s projectile output.
        if (_weapon.allowProjectileMod && _character.resourceType != "none") {
            mods.projectileType = _character.resourceType;
            
            // Example: special cases for a cannon archetype
            if (_weapon.id == "cannon") {
                switch(_character.resourceType) {
                    case "daggers":
                        mods.projectileType = "dagger_spread";
                        _tier1Mods.recoil *= 1.5; // Rogue struggles with kick
                        break;
                    case "holy_water":
                        mods.projectileType = "holy_blast";
                        _tier1Mods.recoil *= 1.8; // Cleric fares worse
                        break;
                    case "bombs":
                        mods.projectileType = "cluster_bomb";
                        _tier1Mods.recoil *= 0.8; // Demolitionist absorbs
                        break;
                }
            }
        }
        
        // === AFFINITY EFFECTS ===
        // Pick a single dominant synergy by multiplying char vs weapon values.
        var strongestAffinity = "";
        var strongestValue = 0;
        
        var affinities = variable_struct_get_names(_character.affinities);
        for (var i = 0; i < array_length(affinities); i++) {
            var aff = affinities[i];
            var charValue = _character.affinities[$ aff];
            var weapValue = _weapon.affinityCompatibility[$ aff];
            
            if (charValue * weapValue > strongestValue) {
                strongestValue = charValue * weapValue;
                strongestAffinity = aff;
            }
        }
        
        if (strongestValue > 20) { // Threshold: strong match only
            array_push(mods.attackEffects, strongestAffinity + "_infusion");
            // Thematic extras per school
            switch(strongestAffinity) {
                case "holy":
                    array_push(mods.attackEffects, "healing_aura");
                    break;
                case "chaos":
                    array_push(mods.attackEffects, "random_proc");
                    break;
                case "shadow":
                    array_push(mods.attackEffects, "lifesteal");
                    break;
            }
        }
        
        return mods;
    };
    
    // TIER 3: Extreme cases - complete transformation
    // When handling is far out of band—or perfectly matched with affinity—
    // the moveset identity changes. Outputs a label for VFX/logic hooks.
    applyTier3Transformation = function(_weapon, _character, _tier1Mods, _tier2Mods) {
        var handling = _character.getHandlingRating(_weapon.weightClass);
        var transform = "none";
        
        // === TOO HEAVY TRANSFORMATION ===
        if (handling < _weapon.transformations.tooHeavy) {
            transform = "dragging";
            
            // Different moveset: slow drags into a slam, high payoff
            _tier2Mods.comboPattern = ["drag", "drag", "slam"];
            _tier2Mods.specialFinisher = "exhausted_collapse";
            _tier1Mods.attackSpeed = 0.3;
            _tier1Mods.damage *= 1.5; // Big when it lands
            
            // Tiny wielders enter slapstick mode
            if (_character.size < 3) {
                transform = "comedy_drag";
                _tier2Mods.attackEffects = ["sparks_trail", "struggle_sounds"];
            }
        }
        
        // === TOO LIGHT TRANSFORMATION ===
        else if (handling > _weapon.transformations.tooLight) {
            transform = "flourish";
            
            // One‑handed flourishy string, very fast sequencing
            _tier2Mods.comboPattern = ["spin", "spin", "toss", "catch", "strike"];
            _tier2Mods.specialFinisher = "juggle_finish";
            _tier1Mods.attackSpeed = 2.0;
        }
        
        // === PERFECT MATCH TRANSFORMATION ===
        else if (abs(handling - _weapon.transformations.perfect) < 0.1) {
            // Perfect handling *and* strong affinity unlocks awakened state
            var perfectAffinity = false;
            var affinities = variable_struct_get_names(_character.affinities);
            
            for (var i = 0; i < array_length(affinities); i++) {
                var aff = affinities[i];
                if (_character.affinities[$ aff] >= 8 && 
                    _weapon.affinityCompatibility[$ aff] >= 8) {
                    perfectAffinity = true;
                    transform = "awakened_" + aff;
                    break;
                }
            }
            
            if (perfectAffinity) {
                // Ultimate dial‑up: all numbers and pattern converge
                _tier1Mods.damage *= 2;
                _tier1Mods.knockback *= 1.5;
                _tier2Mods.comboPattern = ["ultimate", "ultimate", "ultimate"];
                _tier2Mods.specialFinisher = "limit_break";
                array_push(_tier2Mods.attackEffects, "glowing_aura");
            }
        }
        
        // === COMEDY COMBINATIONS ===
        // Tiny character + high recoil → physics gag
        if (_character.size <= 2 && _weapon.baseRecoil > 20) {
            transform = "rocket_jump";
            array_push(_tier2Mods.attackEffects, "self_launch");
            _tier1Mods.recoil = 50; // Forces backward impulse
        }
        
        // Low technique + rapier archetype → chaotic but lucky crit
        if (_character.technique <= 2 && _weapon.id == "rapier") {
            transform = "accidental_genius";
            _tier2Mods.comboPattern = ["fumble", "trip", "accidentally_crit"];
        }
        
        return transform;
    };
    
    // Main function to get all modifications
    // Returns a packaged result (stats/behaviors/transformation) with an
    // applyToInstance() helper for wiring to a spawned weapon/melee object.
    getFullModifications = function(_weapon, _character) {
        // Apply all three tiers
        var tier1 = applyTier1Mods(_weapon, _character);
        var tier2 = applyTier2Mods(_weapon, _character, tier1);
        var transformation = applyTier3Transformation(_weapon, _character, tier1, tier2);
        
        return {
            stats: tier1,
            behaviors: tier2,
            transformation: transformation,
            
            // Convenience function for applying to weapon instance
            applyToInstance: function(_instance) {
                _instance.damage = stats.damage;
                _instance.knockback = stats.knockback;
                _instance.attackSpeed = stats.attackSpeed;
                _instance.comboPattern = behaviors.comboPattern;
                _instance.transformation = transformation;
                
                // Store for special attack handling (finishers/effect tags)
                _instance.specialFinisher = behaviors.specialFinisher;
                _instance.attackEffects = behaviors.attackEffects;
            }
        };
    };
}

// Example authoring helper to visualize system extremes in tools/tests.
function createExampleCharacters() {
    var chars = {};
    
    // Tiny rogue — excels at finesse, throws daggers, light body = low recoil
    var rogue = new CharacterTraits("rogue");
    rogue.strength = 3;
    rogue.weight = 2;
    rogue.size = 2;
    rogue.balance = 7;
    rogue.finesse = 9;
    rogue.technique = 7;
    rogue.resourceType = "daggers";
    rogue.resourceCount = 20;
    chars.rogue = rogue;
    
    // Heavy priest — slow rhythm, strong holy affinity, supports cannon combos
    var priest = new CharacterTraits("priest");
    priest.strength = 4;
    priest.weight = 5;
    priest.size = 5;
    priest.balance = 3;
    priest.rhythm = 3; // Slow and methodical
    priest.affinities.holy = 9;
    priest.resourceType = "holy_water";
    chars.priest = priest;
    
    // Tiny chaos goblin — poor control, high chaos synergy, random throwables
    var goblin = new CharacterTraits("goblin");
    goblin.strength = 2;
    goblin.weight = 1;
    goblin.size = 1;
    goblin.balance = 2; // Terrible balance
    goblin.technique = 1; // No technique
    goblin.affinities.chaos = 10;
    goblin.resourceType = "random_junk";
    chars.goblin = goblin;
    
    return chars;
}
