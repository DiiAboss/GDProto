
// ===== THREE-TIER MODIFICATION SYSTEM =====

function WeaponModificationSystem() constructor {
    
    // TIER 1: Always happens - basic stat scaling
    applyTier1Mods = function(_weapon, _character) {
        var mods = {
            damage: _weapon.baseDamage,
            knockback: _weapon.baseKnockback,
            attackSpeed: 1.0,
            recoil: _weapon.baseRecoil,
            range: _weapon.baseRange
        };
        
        // Handling affects everything
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
            mods.damage *= 0.9; // Less impact
        }
        
        // Rhythm affects attack speed
        mods.attackSpeed *= (0.5 + _character.rhythm / 10);
        
        // Balance affects recoil
        var recoilReduction = _character.balance * 2 + _character.weight * 1.5;
        mods.recoil = max(0, mods.recoil - recoilReduction);
        
        return mods;
    };
    
    // TIER 2: Conditional - behavior modifications
    applyTier2Mods = function(_weapon, _character, _tier1Mods) {
        var mods = {
            comboPattern: _weapon.baseComboPattern,
            projectileType: "default",
            specialFinisher: "none",
            attackEffects: []
        };
        
        // === COMBO MODIFICATIONS ===
        if (_weapon.allowComboMods) {
            // Finesse characters add light attacks
            if (_character.finesse > 7) {
                array_insert(mods.comboPattern, 0, "light");
                
                // Rogue-type gets dagger throw finisher
                if (_character.resourceType == "daggers") {
                    mods.specialFinisher = "dagger_throw";
                }
            }
            
            // Brutal characters add heavy attacks
            if (_character.brutality > 7) {
                array_push(mods.comboPattern, "heavy");
                
                // Big character gets ground slam finisher
                if (_character.size > 7) {
                    mods.specialFinisher = "ground_slam";
                }
            }
            
            // Technical characters get precise patterns
            if (_character.technique > 7) {
                // Perfect alternating pattern
                mods.comboPattern = ["light", "heavy", "light", "heavy"];
                mods.specialFinisher = "precision_strike";
            }
        }
        
        // === PROJECTILE MODIFICATIONS ===
        if (_weapon.allowProjectileMod && _character.resourceType != "none") {
            mods.projectileType = _character.resourceType;
            
            // Special combinations
            if (_weapon.id == "cannon") {
                switch(_character.resourceType) {
                    case "daggers":
                        mods.projectileType = "dagger_spread";
                        _tier1Mods.recoil *= 1.5; // Rogue can't handle cannon recoil
                        break;
                    case "holy_water":
                        mods.projectileType = "holy_blast";
                        _tier1Mods.recoil *= 1.8; // Priest really can't handle it
                        break;
                    case "bombs":
                        mods.projectileType = "cluster_bomb";
                        _tier1Mods.recoil *= 0.8; // Demolition expert handles it better
                        break;
                }
            }
        }
        
        // === AFFINITY EFFECTS ===
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
        
        if (strongestValue > 20) { // Strong affinity match
            array_push(mods.attackEffects, strongestAffinity + "_infusion");
            
            // Specific affinity bonuses
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
    applyTier3Transformation = function(_weapon, _character, _tier1Mods, _tier2Mods) {
        var handling = _character.getHandlingRating(_weapon.weightClass);
        var transform = "none";
        
        // === TOO HEAVY TRANSFORMATION ===
        if (handling < _weapon.transformations.tooHeavy) {
            transform = "dragging";
            
            // Completely different moveset
            _tier2Mods.comboPattern = ["drag", "drag", "slam"];
            _tier2Mods.specialFinisher = "exhausted_collapse";
            _tier1Mods.attackSpeed = 0.3;
            _tier1Mods.damage *= 1.5; // But hits hard when it connects
            
            // Comedy factor
            if (_character.size < 3) {
                transform = "comedy_drag";
                _tier2Mods.attackEffects = ["sparks_trail", "struggle_sounds"];
            }
        }
        
        // === TOO LIGHT TRANSFORMATION ===
        else if (handling > _weapon.transformations.tooLight) {
            transform = "flourish";
            
            // Weapon becomes one-handed, fancy moves
            _tier2Mods.comboPattern = ["spin", "spin", "toss", "catch", "strike"];
            _tier2Mods.specialFinisher = "juggle_finish";
            _tier1Mods.attackSpeed = 2.0;
        }
        
        // === PERFECT MATCH TRANSFORMATION ===
        else if (abs(handling - _weapon.transformations.perfect) < 0.1) {
            // Check for perfect affinity match too
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
                // Weapon achieves ultimate form
                _tier1Mods.damage *= 2;
                _tier1Mods.knockback *= 1.5;
                _tier2Mods.comboPattern = ["ultimate", "ultimate", "ultimate"];
                _tier2Mods.specialFinisher = "limit_break";
                array_push(_tier2Mods.attackEffects, "glowing_aura");
            }
        }
        
        // === COMEDY COMBINATIONS ===
        // Tiny character with explosion weapon
        if (_character.size <= 2 && _weapon.baseRecoil > 20) {
            transform = "rocket_jump";
            array_push(_tier2Mods.attackEffects, "self_launch");
            _tier1Mods.recoil = 50; // Launches them backward hilariously
        }
        
        // Clumsy character with precision weapon
        if (_character.technique <= 2 && _weapon.id == "rapier") {
            transform = "accidental_genius";
            _tier2Mods.comboPattern = ["fumble", "trip", "accidentally_crit"];
        }
        
        return transform;
    };
    
    // Main function to get all modifications
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
                
                // Store for special attack handling
                _instance.specialFinisher = behaviors.specialFinisher;
                _instance.attackEffects = behaviors.attackEffects;
            }
        };
    };
}


