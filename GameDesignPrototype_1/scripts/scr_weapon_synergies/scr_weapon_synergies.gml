// ==========================================
// DYNAMIC WEAPON SYNERGY SYSTEM
// ==========================================

/// @desc Initialize the dynamic synergy system (call during game init)
function InitWeaponSynergySystem() {
    global.SynergyData = {};
    global.SynergyRules = [];
    global.SynergyClassTags = {};
    global.SynergyWeaponTags = {};

    // ------------------------------------------
    // CLASS TAGS
    // ------------------------------------------
    global.SynergyClassTags[$ string(CharacterClass.WARRIOR)] = [
        "PLAYER", "CLASS_WARRIOR", "MELEE", "BRUTE"
    ];
    global.SynergyClassTags[$ string(CharacterClass.HOLY_MAGE)] = [
        "PLAYER", "CLASS_MAGE", "ARCANE", "HOLY"
    ];
    global.SynergyClassTags[$ string(CharacterClass.VAMPIRE)] = [
        "PLAYER", "CLASS_VAMPIRE", "BLOOD", "UNDEAD"
    ];

    // Placeholder for future class additions
    global.SynergyClassTags[$ "BASEBALL_CLASS"] = [
        "PLAYER", "CLASS_BASEBALL", "MELEE", "ATHLETE"
    ];

    // ------------------------------------------
    // WEAPON TAGS
    // ------------------------------------------
    global.SynergyWeaponTags[$ string(Weapon.Sword)] = [
        "WEAPON", "MELEE", "SWORD", "BLADE"
    ];
    global.SynergyWeaponTags[$ string(Weapon.Dagger)] = [
        "WEAPON", "MELEE", "DAGGER", "BLADE", "PIERCE"
    ];
    global.SynergyWeaponTags[$ string(Weapon.BaseballBat)] = [
        "WEAPON", "MELEE", "BAT", "BLUNT"
    ];
    global.SynergyWeaponTags[$ string(Weapon.Holy_Water)] = [
        "WEAPON", "GRENADE", "EXPLOSIVE", "HOLY"
    ];
    global.SynergyWeaponTags[$ string(Weapon.Bow)] = [
        "WEAPON", "RANGED", "BOW", "PROJECTILE"
    ];
    global.SynergyWeaponTags[$ string(Weapon.Boomerang)] = [
        "WEAPON", "RANGED", "BOOMERANG", "THROWN"
    ];
    global.SynergyWeaponTags[$ string(Weapon.ChargeCannon)] = [
        "WEAPON", "RANGED", "CANNON", "EXPLOSIVE"
    ];
    global.SynergyWeaponTags[$ string(Weapon.ChainWhip)] = [
        "WEAPON", "MELEE", "WHIP", "CHAIN"
    ];
    global.SynergyWeaponTags[$ string(Weapon.ThrowableItem)] = [
        "WEAPON", "THROWABLE"
    ];

    // ------------------------------------------
    // SYNERGY DATA DEFINITIONS
    // ------------------------------------------
    global.SynergyData.SPELL_BASEBALL = {
        key: "SPELL_BASEBALL",
        type: SynergyType.SPELL_BASEBALL,
        damage_mult: 0.7,
        knockback_mult: 0.6,
        attack_speed_mult: 1.0,
        projectile: obj_magic_baseball,
        projectile_behavior: SynergyProjectileBehavior.ON_SWING,
        projectile_count: 2,
        projectile_spread: 30
    };

    global.SynergyData.ARCANE_BLADE = {
        key: "ARCANE_BLADE",
        type: SynergyType.ARCANE_BLADE,
        damage_mult: 0.8,
        knockback_mult: 0.7,
        attack_speed_mult: 1.2,
        projectile: obj_arcane_slash,
        projectile_behavior: SynergyProjectileBehavior.ON_SWING,
        projectile_count: 1
    };

    global.SynergyData.HOLY_BOMB = {
        key: "HOLY_BOMB",
        type: SynergyType.HOLY_GRENADE,
        damage_mult: 1.5,
        knockback_mult: 1.0,
        attack_speed_mult: 1.0,
        explosion_radius_mult: 1.3,
        projectile: obj_holy_water,
        projectile_behavior: SynergyProjectileBehavior.THROW_STYLE,
        throw_style: "holy_arc"
    };

    global.SynergyData.HOMERUN_MASTER = {
        key: "HOMERUN_MASTER",
        type: SynergyType.HOMERUN_MASTER,
        damage_mult: 1.3,
        knockback_mult: 2.5,
        attack_speed_mult: 0.9,
        homerun_chance: 0.35,
        projectile_behavior: SynergyProjectileBehavior.NONE
    };

    global.SynergyData.FASTBALL_GRENADE = {
        key: "FASTBALL_GRENADE",
        type: SynergyType.FASTBALL_THROW,
        damage_mult: 1.0,
        knockback_mult: 1.0,
        attack_speed_mult: 1.0,
        throw_speed_mult: 2.0,
        projectile_behavior: SynergyProjectileBehavior.THROW_STYLE,
        throw_style: "fastball",
        projectile: obj_grenade
    };

    global.SynergyData.BRUTAL_SWING = {
        key: "BRUTAL_SWING",
        type: SynergyType.BRUTAL_SWING,
        damage_mult: 1.5,
        knockback_mult: 1.8,
        attack_speed_mult: 0.7,
        projectile_behavior: SynergyProjectileBehavior.NONE
    };

    global.SynergyData.RAGE_BLADE = {
        key: "RAGE_BLADE",
        type: SynergyType.RAGE_BLADE,
        damage_mult: 1.2,
        knockback_mult: 1.1,
        attack_speed_mult: 1.0,
        rage_gain_on_hit: 0.15,
        projectile_behavior: SynergyProjectileBehavior.NONE
    };

    global.SynergyData.BLOOD_BAT = {
        key: "BLOOD_BAT",
        type: SynergyType.BLOOD_BAT,
        damage_mult: 1.0,
        knockback_mult: 1.0,
        attack_speed_mult: 1.0,
        lifesteal_bonus: 0.10,
        projectile_behavior: SynergyProjectileBehavior.NONE
    };

    global.SynergyData.CRIMSON_BLADE = {
        key: "CRIMSON_BLADE",
        type: SynergyType.CRIMSON_BLADE,
        damage_mult: 1.1,
        knockback_mult: 0.9,
        attack_speed_mult: 1.0,
        projectile: obj_blood_projectile,
        projectile_behavior: SynergyProjectileBehavior.ON_HIT,
        projectile_count: 3,
        lifesteal_bonus: 0.05
    };

    global.SynergyData.LIFESTEAL_BOMB = {
        key: "LIFESTEAL_BOMB",
        type: SynergyType.LIFESTEAL_GRENADE,
        damage_mult: 1.2,
        knockback_mult: 1.0,
        attack_speed_mult: 1.0,
        lifesteal_percent: 0.25,
        projectile: obj_grenade,
        projectile_behavior: SynergyProjectileBehavior.THROW_STYLE,
        throw_style: "blood_arc"
    };

    // Maintain legacy alias for compatibility if other systems still reference global.WeaponSynergies
    global.WeaponSynergies = global.SynergyData;

    // ------------------------------------------
    // SYNERGY RULES (TAG BASED)
    // ------------------------------------------
    global.SynergyRules = [
        {
            synergy_key: "SPELL_BASEBALL",
            groups: [
                { tags: ["CLASS_MAGE"], sources: ["player"] },
                { tags: ["BAT"], sources: ["weapon"] }
            ]
        },
        {
            synergy_key: "ARCANE_BLADE",
            groups: [
                { tags: ["CLASS_MAGE"], sources: ["player"] },
                { tags: ["SWORD"], sources: ["weapon"] }
            ]
        },
        {
            synergy_key: "HOLY_BOMB",
            groups: [
                { tags: ["CLASS_MAGE"], sources: ["player"] },
                { tags: ["EXPLOSIVE"], sources: ["weapon"] }
            ]
        },
        {
            synergy_key: "HOMERUN_MASTER",
            groups: [
                { tags: ["CLASS_BASEBALL"], sources: ["player"] },
                { tags: ["BAT"], sources: ["weapon"] }
            ]
        },
        {
            synergy_key: "FASTBALL_GRENADE",
            groups: [
                { tags: ["CLASS_BASEBALL"], sources: ["player"] },
                { tags: ["GRENADE"], sources: ["weapon"] }
            ]
        },
        {
            synergy_key: "BRUTAL_SWING",
            groups: [
                { tags: ["CLASS_WARRIOR"], sources: ["player"] },
                { tags: ["BAT"], sources: ["weapon"] }
            ]
        },
        {
            synergy_key: "RAGE_BLADE",
            groups: [
                { tags: ["CLASS_WARRIOR"], sources: ["player"] },
                { tags: ["SWORD"], sources: ["weapon"] }
            ]
        },
        {
            synergy_key: "BLOOD_BAT",
            groups: [
                { tags: ["CLASS_VAMPIRE"], sources: ["player"] },
                { tags: ["BAT"], sources: ["weapon"] }
            ]
        },
        {
            synergy_key: "CRIMSON_BLADE",
            groups: [
                { tags: ["CLASS_VAMPIRE"], sources: ["player"] },
                { tags: ["SWORD"], sources: ["weapon"] }
            ]
        },
        {
            synergy_key: "LIFESTEAL_BOMB",
            groups: [
                { tags: ["CLASS_VAMPIRE"], sources: ["player"] },
                { tags: ["EXPLOSIVE"], sources: ["weapon"] }
            ]
        }
    ];
}

// ------------------------------------------
// TAG UTILITIES
// ------------------------------------------
function GetClassSynergyTags(_class) {
    var key = string(_class);
    if (variable_struct_exists(global.SynergyClassTags, key)) {
        return SynergyDeepCopyArray(global.SynergyClassTags[$ key]);
    }
    return [];
}

function GetWeaponSynergyTags(_weapon_id) {
    var key = string(_weapon_id);
    if (variable_struct_exists(global.SynergyWeaponTags, key)) {
        return SynergyDeepCopyArray(global.SynergyWeaponTags[$ key]);
    }
    return [];
}

function SynergyEnsureArray(_value) {
    if (_value == undefined) return [];
    if (is_array(_value)) return _value;
    return [_value];
}

function SynergyArrayContains(_array, _value) {
    if (!is_array(_array)) return false;
    for (var i = 0; i < array_length(_array); i++) {
        if (_array[i] == _value) return true;
    }
    return false;
}

function SynergyArrayPushUnique(_array, _value) {
    if (!SynergyArrayContains(_array, _value)) {
        array_push(_array, _value);
    }
    return _array;
}

function SynergyStringEndsWith(_value, _suffix) {
    if (!is_string(_value) || !is_string(_suffix)) return false;
    var suffix_len = string_length(_suffix);
    if (suffix_len == 0) return true;
    if (string_length(_value) < suffix_len) return false;
    return string_copy(_value, string_length(_value) - suffix_len + 1, suffix_len) == _suffix;
}

function SynergyDeepCopyArray(_array) {
    if (!is_array(_array)) return [];
    var len = array_length(_array);
    var result = array_create(len);
    for (var i = 0; i < len; i++) {
        var value = _array[i];
        if (is_array(value)) {
            result[i] = SynergyDeepCopyArray(value);
        } else if (is_struct(value)) {
            result[i] = SynergyDeepCopyStruct(value);
        } else {
            result[i] = value;
        }
    }
    return result;
}

function SynergyDeepCopyStruct(_struct) {
    if (!is_struct(_struct)) return {};
    var names = struct_get_names(_struct);
    var copy = {};
    for (var i = 0; i < array_length(names); i++) {
        var name = names[i];
        var value = _struct[$ name];
        if (is_array(value)) {
            copy[$ name] = SynergyDeepCopyArray(value);
        } else if (is_struct(value)) {
            copy[$ name] = SynergyDeepCopyStruct(value);
        } else {
            copy[$ name] = value;
        }
    }
    return copy;
}

function EnsureWeaponInstance(_weapon_struct) {
    if (_weapon_struct == undefined) return undefined;

    if (is_struct(_weapon_struct) && variable_struct_exists(_weapon_struct, "__is_instance") && _weapon_struct.__is_instance) {
        return _weapon_struct;
    }

    var clone = SynergyDeepCopyStruct(_weapon_struct);
    clone.__is_instance = true;

    if (!variable_struct_exists(clone, "synergy_tags") || !is_array(clone.synergy_tags)) {
        clone.synergy_tags = GetWeaponSynergyTags(clone.id);
    }

    return clone;
}

function SynergyGetTagsFromSource(_source) {
    if (_source == undefined) return [];

    if (is_struct(_source)) {
        if (variable_struct_exists(_source, "synergy_tags") && is_array(_source.synergy_tags)) {
            return SynergyDeepCopyArray(_source.synergy_tags);
        }
        if (variable_struct_exists(_source, "tags") && is_array(_source.tags)) {
            return SynergyDeepCopyArray(_source.tags);
        }
    } else {
        if (variable_instance_exists(_source, "synergy_tags") && is_array(_source.synergy_tags)) {
            return SynergyDeepCopyArray(_source.synergy_tags);
        }
        if (variable_instance_exists(_source, "tags") && is_array(_source.tags)) {
            return SynergyDeepCopyArray(_source.tags);
        }
    }

    return [];
}

function SynergyTagsMatch(_source_tags, _required_tags, _mode) {
    if (!is_array(_required_tags) || array_length(_required_tags) == 0) return true;
    if (!is_array(_source_tags) || array_length(_source_tags) == 0) return false;

    var mode = (_mode == undefined) ? SynergyTagMatch.ALL : _mode;

    switch (mode) {
        case SynergyTagMatch.ANY:
            for (var i = 0; i < array_length(_required_tags); i++) {
                if (SynergyArrayContains(_source_tags, _required_tags[i])) return true;
            }
            return false;

        default: // SynergyTagMatch.ALL
            for (var j = 0; j < array_length(_required_tags); j++) {
                if (!SynergyArrayContains(_source_tags, _required_tags[j])) return false;
            }
            return true;
    }
}

function SynergyGroupMatches(_group, _sources) {
    if (!is_struct(_group)) return false;
    var tags_required = SynergyEnsureArray(_group.tags);

    if (array_length(tags_required) == 0) return true;

    var allowed_sources = SynergyEnsureArray(_group.sources);
    var mode = (variable_struct_exists(_group, "mode")) ? _group.mode : SynergyTagMatch.ALL;

    for (var i = 0; i < array_length(_sources); i++) {
        var src = _sources[i];
        var src_tags = src.tags;
        var src_label = src.label;

        if (array_length(allowed_sources) > 0 && !SynergyArrayContains(allowed_sources, src_label)) {
            continue;
        }

        if (SynergyTagsMatch(src_tags, tags_required, mode)) {
            return true;
        }
    }

    return false;
}

function SynergyRuleMatches(_rule, _sources) {
    if (!is_struct(_rule)) return false;
    var groups = _rule.groups;
    if (!is_array(groups) || array_length(groups) == 0) return false;

    for (var i = 0; i < array_length(groups); i++) {
        if (!SynergyGroupMatches(groups[i], _sources)) {
            return false;
        }
    }
    return true;
}

function EvaluateDynamicSynergies(_player, _weapon_struct, _extra_sources) {
    if (_weapon_struct == undefined) return [];

    var sources = [];
    array_push(sources, { label: "player", tags: SynergyGetTagsFromSource(_player) });
    array_push(sources, { label: "weapon", tags: SynergyGetTagsFromSource(_weapon_struct) });

    if (_extra_sources != undefined) {
        if (is_array(_extra_sources)) {
            for (var i = 0; i < array_length(_extra_sources); i++) {
                var entry = _extra_sources[i];
                if (entry == undefined) continue;

                var label = "extra_" + string(i);
                var tags = [];

                if (is_struct(entry)) {
                    if (variable_struct_exists(entry, "label")) {
                        label = entry.label;
                    }
                    tags = SynergyGetTagsFromSource(entry);
                } else if (is_array(entry)) {
                    tags = SynergyDeepCopyArray(entry);
                }

                if (array_length(tags) > 0) {
                    array_push(sources, { label: label, tags: tags });
                }
            }
        } else if (is_struct(_extra_sources)) {
            var label_single = variable_struct_exists(_extra_sources, "label") ? _extra_sources.label : "extra";
            var tags_single = SynergyGetTagsFromSource(_extra_sources);
            if (array_length(tags_single) > 0) {
                array_push(sources, { label: label_single, tags: tags_single });
            }
        }
    }

    var results = [];
    if (!is_array(global.SynergyRules)) return results;

    for (var r = 0; r < array_length(global.SynergyRules); r++) {
        var rule = global.SynergyRules[r];
        if (!is_struct(rule)) continue;

        if (SynergyRuleMatches(rule, sources)) {
            var key = rule.synergy_key;
            if (key != undefined && variable_struct_exists(global.SynergyData, key)) {
                array_push(results, global.SynergyData[$ key]);
            }
        }
    }

    return results;
}

function CombineSynergyData(_synergy_list) {
    var combined = {
        key: "NONE",
        keys: [],
        type: SynergyType.NONE,
        damage_mult: 1.0,
        knockback_mult: 1.0,
        attack_speed_mult: 1.0,
        projectile_behavior: SynergyProjectileBehavior.NONE,
        projectile: noone,
        projectile_count: 0,
        projectile_spread: 0
    };

    if (!is_array(_synergy_list)) return combined;

    for (var i = 0; i < array_length(_synergy_list); i++) {
        var synergy = _synergy_list[i];
        if (!is_struct(synergy)) continue;

        var key = variable_struct_exists(synergy, "key") ? synergy.key : "";
        if (key != "") {
            array_push(combined.keys, key);
            combined.key = key;
        }

        if (variable_struct_exists(synergy, "type") && synergy.type != SynergyType.NONE) {
            combined.type = synergy.type;
        }

        combined.damage_mult *= (variable_struct_exists(synergy, "damage_mult")) ? synergy.damage_mult : 1.0;
        combined.knockback_mult *= (variable_struct_exists(synergy, "knockback_mult")) ? synergy.knockback_mult : 1.0;
        combined.attack_speed_mult *= (variable_struct_exists(synergy, "attack_speed_mult")) ? synergy.attack_speed_mult : 1.0;

        if (variable_struct_exists(synergy, "projectile_behavior") && synergy.projectile_behavior != SynergyProjectileBehavior.NONE) {
            combined.projectile_behavior = synergy.projectile_behavior;
            combined.projectile = variable_struct_exists(synergy, "projectile") ? synergy.projectile : combined.projectile;
            combined.projectile_count = variable_struct_exists(synergy, "projectile_count") ? synergy.projectile_count : max(1, combined.projectile_count);
            combined.projectile_spread = variable_struct_exists(synergy, "projectile_spread") ? synergy.projectile_spread : combined.projectile_spread;
        }

        var names = struct_get_names(synergy);
        for (var n = 0; n < array_length(names); n++) {
            var name = names[n];
            if (name == "key" || name == "type" || name == "damage_mult" || name == "knockback_mult" ||
                name == "attack_speed_mult" || name == "projectile_behavior" || name == "projectile" ||
                name == "projectile_count" || name == "projectile_spread") {
                continue;
            }

            var value = synergy[$ name];
            if (is_real(value)) {
                if (SynergyStringEndsWith(name, "_mult")) {
                    combined[$ name] = (variable_struct_exists(combined, name) ? combined[$ name] : 1.0) * value;
                } else if (SynergyStringEndsWith(name, "_bonus") || SynergyStringEndsWith(name, "_chance") || SynergyStringEndsWith(name, "_percent")) {
                    combined[$ name] = (variable_struct_exists(combined, name) ? combined[$ name] : 0) + value;
                } else {
                    combined[$ name] = value;
                }
            } else {
                combined[$ name] = value;
            }
        }
    }

    if (combined.projectile_count <= 0 && combined.projectile_behavior != SynergyProjectileBehavior.NONE) {
        combined.projectile_count = 1;
    }

    return combined;
}

function ResetWeaponSynergyState(_weapon_struct) {
    if (!is_struct(_weapon_struct)) return;

    if (!variable_struct_exists(_weapon_struct, "__synergy_base")) {
        var base_combo = [];
        if (variable_struct_exists(_weapon_struct, "combo_attacks") && is_array(_weapon_struct.combo_attacks)) {
            for (var i = 0; i < array_length(_weapon_struct.combo_attacks); i++) {
                var attack = _weapon_struct.combo_attacks[i];
                if (is_struct(attack)) {
                    array_push(base_combo, {
                        damage_mult: attack.damage_mult,
                        knockback_mult: attack.knockback_mult,
                        duration: attack.duration
                    });
                }
            }
        }

        _weapon_struct.__synergy_base = {
            combo_attacks: base_combo,
            spawn_projectiles: variable_struct_exists(_weapon_struct, "spawn_projectiles") ? _weapon_struct.spawn_projectiles : false,
            projectile_type: variable_struct_exists(_weapon_struct, "projectile_type") ? _weapon_struct.projectile_type : noone,
            projectile_behavior: variable_struct_exists(_weapon_struct, "projectile_behavior") ? _weapon_struct.projectile_behavior : SynergyProjectileBehavior.NONE,
            projectile_count: variable_struct_exists(_weapon_struct, "projectile_count") ? _weapon_struct.projectile_count : 0,
            projectile_spread: variable_struct_exists(_weapon_struct, "projectile_spread") ? _weapon_struct.projectile_spread : 0,
            field_defaults: {}
        };
    }

    var base = _weapon_struct.__synergy_base;

    if (variable_struct_exists(_weapon_struct, "combo_attacks") && is_array(base.combo_attacks)) {
        for (var j = 0; j < array_length(base.combo_attacks); j++) {
            if (j >= array_length(_weapon_struct.combo_attacks)) continue;
            var original = base.combo_attacks[j];
            if (!is_struct(original)) continue;
            _weapon_struct.combo_attacks[j].damage_mult = original.damage_mult;
            _weapon_struct.combo_attacks[j].knockback_mult = original.knockback_mult;
            _weapon_struct.combo_attacks[j].duration = original.duration;
        }
    }

    _weapon_struct.spawn_projectiles = base.spawn_projectiles;
    _weapon_struct.projectile_type = base.projectile_type;
    _weapon_struct.projectile_behavior = base.projectile_behavior;
    _weapon_struct.projectile_count = base.projectile_count;
    _weapon_struct.projectile_spread = base.projectile_spread;

    if (variable_struct_exists(_weapon_struct, "__synergy_fields_applied")) {
        var applied = _weapon_struct.__synergy_fields_applied;
        if (is_array(applied)) {
            for (var i = 0; i < array_length(applied); i++) {
                var field = applied[i];
                if (variable_struct_exists(base.field_defaults, field)) {
                    var value = base.field_defaults[$ field];
                    if (value == undefined) {
                        if (variable_struct_exists(_weapon_struct, field)) {
                            struct_delete(_weapon_struct, field);
                        }
                    } else {
                        _weapon_struct[$ field] = value;
                    }
                } else if (variable_struct_exists(_weapon_struct, field)) {
                    struct_delete(_weapon_struct, field);
                }
            }
        }
    }

    _weapon_struct.__synergy_fields_applied = [];
    _weapon_struct.active_synergy = undefined;
    _weapon_struct.active_synergies = [];
}

function SynergySetWeaponField(_weapon_struct, _field, _value) {
    if (!is_struct(_weapon_struct)) return;
    var base = _weapon_struct.__synergy_base;
    if (!is_struct(base)) return;

    if (!variable_struct_exists(base, "field_defaults")) {
        base.field_defaults = {};
    }

    if (!variable_struct_exists(base.field_defaults, _field)) {
        if (variable_struct_exists(_weapon_struct, _field)) {
            base.field_defaults[$ _field] = _weapon_struct[$ _field];
        } else {
            base.field_defaults[$ _field] = undefined;
        }
    }

    _weapon_struct[$ _field] = _value;

    if (!variable_struct_exists(_weapon_struct, "__synergy_fields_applied")) {
        _weapon_struct.__synergy_fields_applied = [];
    }

    if (!SynergyArrayContains(_weapon_struct.__synergy_fields_applied, _field)) {
        array_push(_weapon_struct.__synergy_fields_applied, _field);
    }
}

function ApplySynergiesToWeapon(_weapon_struct, _synergy_list, _player) {
    if (!is_struct(_weapon_struct)) return;

    ResetWeaponSynergyState(_weapon_struct);

    if (!is_array(_synergy_list) || array_length(_synergy_list) == 0) {
        if (instance_exists(_player) && instance_exists(_player.melee_weapon)) {
            _player.melee_weapon.synergy_data = undefined;
        }
        return;
    }

    var combined = CombineSynergyData(_synergy_list);

    if (variable_struct_exists(_weapon_struct, "combo_attacks") && is_array(_weapon_struct.combo_attacks)) {
        var base_combo = _weapon_struct.__synergy_base.combo_attacks;
        for (var i = 0; i < array_length(base_combo); i++) {
            if (i >= array_length(_weapon_struct.combo_attacks)) continue;
            var original = base_combo[i];
            if (!is_struct(original)) continue;

            _weapon_struct.combo_attacks[i].damage_mult = original.damage_mult * combined.damage_mult;
            _weapon_struct.combo_attacks[i].knockback_mult = original.knockback_mult * combined.knockback_mult;
            _weapon_struct.combo_attacks[i].duration = max(1, original.duration / combined.attack_speed_mult);
        }
    }

    if (combined.projectile_behavior != SynergyProjectileBehavior.NONE) {
        SynergySetWeaponField(_weapon_struct, "spawn_projectiles", true);
        SynergySetWeaponField(_weapon_struct, "projectile_type", combined.projectile);
        SynergySetWeaponField(_weapon_struct, "projectile_behavior", combined.projectile_behavior);
        SynergySetWeaponField(_weapon_struct, "projectile_count", combined.projectile_count);
        SynergySetWeaponField(_weapon_struct, "projectile_spread", combined.projectile_spread);
    }

    var extra_names = struct_get_names(combined);
    for (var n = 0; n < array_length(extra_names); n++) {
        var name = extra_names[n];
        if (name == "key" || name == "keys" || name == "type" || name == "damage_mult" ||
            name == "knockback_mult" || name == "attack_speed_mult" || name == "projectile_behavior" ||
            name == "projectile" || name == "projectile_count" || name == "projectile_spread") {
            continue;
        }

        SynergySetWeaponField(_weapon_struct, name, combined[$ name]);
    }

    _weapon_struct.active_synergy = combined;
    _weapon_struct.active_synergies = combined.keys;

    if (instance_exists(_player) && instance_exists(_player.melee_weapon)) {
        _player.melee_weapon.synergy_data = combined;
    }
}

function RefreshPlayerWeaponSynergies(_player, _weapon_struct) {
    if (!instance_exists(_player)) return;

    var weapon = (_weapon_struct != undefined) ? _weapon_struct : _player.weaponCurrent;
    if (weapon == undefined) return;

    weapon = EnsureWeaponInstance(weapon);

    if (_player.weaponCurrent != weapon && _weapon_struct == undefined) {
        _player.weaponCurrent = weapon;
    }

    var extras = variable_instance_exists(_player, "active_synergy_sources") ? _player.active_synergy_sources : [];
    var synergies = EvaluateDynamicSynergies(_player, weapon, extras);
    ApplySynergiesToWeapon(weapon, synergies, _player);
}
