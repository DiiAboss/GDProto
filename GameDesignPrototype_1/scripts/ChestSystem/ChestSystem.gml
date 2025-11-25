function ChestReward(_type, _id) constructor {
    type = _type;
    id = _id;
    
    name = "";
    desc = "";
    sprite = spr_mod_default;
    rarity = 0;
    
    switch (type) {
        case RewardType.MODIFIER:
            var _mod = get_mod_by_id(_id);
            if (_mod != noone) {
                name = _mod.id;
                if (variable_struct_exists(_mod, "description")) {
                    desc = _mod.description;
                } else {
                    desc = "A powerful modifier";
                }
                sprite = spr_mod_default;
            }
            break;
            
        case RewardType.WEAPON:
            // Get actual weapon data
            var weapon_struct = GetWeaponStructById(_id);
            if (weapon_struct != noone) {
                name = weapon_struct.name;
                desc = "A " + weapon_struct.name;
                
                // Try to get weapon sprite
                if (variable_struct_exists(weapon_struct, "sprite")) {
                    sprite = weapon_struct.sprite;
                }
            } else {
                name = "Mystery Weapon";
                desc = "A mysterious weapon";
            }
            break;
            
        case RewardType.ITEM:
            name = "Item: " + string(_id);
            desc = "A useful item";
            sprite = spr_mod_default;
            break;
    }
}

function GetChestCost(_chests_opened) {
    var base_cost = 100;
    return floor(base_cost * power(1.25, _chests_opened));
}

function GetChestSkipRefund(_cost, _player) {
    var refund_percent = 0.50; // 50% base
    // Later: apply class/modifier bonuses here
    return floor(_cost * refund_percent);
}

function GenerateChestRewards(_chest_type, _chests_opened) {
    var rewards = [];
    
    switch (_chest_type) {
        case ChestType.MINI:
            // 1 random reward
            var rand_type = choose(RewardType.MODIFIER, RewardType.WEAPON, RewardType.ITEM);
            var rand_id = GetRandomRewardID(rand_type);
            array_push(rewards, new ChestReward(rand_type, rand_id));
            break;
            
        case ChestType.GOLD:
            // 3 random rewards, free
            repeat(3) {
                var rand_type = choose(RewardType.MODIFIER, RewardType.WEAPON, RewardType.ITEM);
                var rand_id = GetRandomRewardID(rand_type);
                array_push(rewards, new ChestReward(rand_type, rand_id));
            }
            break;
            
        case ChestType.PREMIUM:
            // Guaranteed rare + extras
            // At least 1 rare
            var rare_type = choose(RewardType.MODIFIER, RewardType.WEAPON);
            var rare_id = GetRandomRewardID(rare_type, true); // true = force rare
            var rare_reward = new ChestReward(rare_type, rare_id);
            rare_reward.rarity = 2; // Mark as rare
            array_push(rewards, rare_reward);
            
            // Add more based on chests opened (scaling rewards)
            var bonus_count = min(2, floor(_chests_opened / 5)); // +1 per 5 chests
            repeat(2 + bonus_count) {
                var rand_type = choose(RewardType.MODIFIER, RewardType.WEAPON, RewardType.ITEM);
                var rand_id = GetRandomRewardID(rand_type);
                array_push(rewards, new ChestReward(rand_type, rand_id));
            }
            break;
    }
    
    return rewards;
}



function GetRandomRewardID(_reward_type, _force_rare = false) {
    // Placeholder - you'll expand this with your actual pools
    switch (_reward_type) {
        case RewardType.MODIFIER:
            // Get random from your modifier pool
            if (array_length(obj_game_manager.allMods) > 0) {
                var rand_mod = obj_game_manager.allMods[irandom(array_length(obj_game_manager.allMods) - 1)];
                return rand_mod.id;
            }
            return "attack_up";
            
        case RewardType.WEAPON:
            return choose(Weapon.Sword, Weapon.Bow, Weapon.Boomerang);
            
        case RewardType.ITEM:
            return "generic_item_" + string(irandom(10));
    }
    
    return "unknown";
}


// INTEGRATION WITH CHEST SYSTEM



// INTEGRATION WITH CHEST SYSTEM


/// @function ApplyReward(_player, _reward)
/// @description Apply a chest reward - weapons spawn on ground, mods apply directly
function ApplyReward(_player, _reward) {
    var reward_type = RewardType.MODIFIER;
    if (variable_struct_exists(_reward, "type")) {
        reward_type = _reward.type;
    }
    
    switch (reward_type) {
        case RewardType.MODIFIER:
            // Apply modifier directly
            AddModifier(_player, _reward.id);
            break;
            
        case RewardType.WEAPON:
            // SPAWN ON GROUND instead of giving directly
            var weapon_struct = GetWeaponStructById(_reward.id);
            
            if (weapon_struct != noone) {
                // Spawn near player with slight offset
                var spawn_x = _player.x + random_range(-32, 32);
                var spawn_y = _player.y + random_range(16, 48);
                
                SpawnWeaponPickup(spawn_x, spawn_y, weapon_struct);
                
                
                // Visual feedback
                var popup = instance_create_depth(_player.x, _player.y - 60, -9999, obj_floating_text);
                popup.text = "WEAPON DROPPED!";
                popup.color = make_color_rgb(255, 150, 50);
            } else {
            }
            break;
            
        case RewardType.ITEM:
            // Your item logic here
            break;
    }
}



function PushbackEnemies(_x, _y, _radius, _force) {
    with (obj_enemy) {
        var dist = point_distance(x, y, _x, _y);
        if (dist <= _radius && dist > 0) {
            var push_dir = point_direction(_x, _y, x, y);
            var push_strength = _force * (1 - (dist / _radius)); // Falloff
			knockback.Apply(push_dir, push_strength);
        }
    }
}

function DestroyAllProjectiles() {
    // Destroy all projectiles with optional particle effect
    with (obj_projectile) {
        // Optional: spawn small particle poof here
        instance_destroy();
    }
    
    // Also destroy enemy projectiles if separate parent
    if (object_exists(obj_enemy_attack_orb)) {
        with (obj_enemy_attack_orb) {
            instance_destroy();
        }
    }
}

function GetChestShakeIntensity(_rewards) {
    // Calculate shake based on highest rarity in rewards
    var max_rarity = 0;
    for (var i = 0; i < array_length(_rewards); i++) {
        if (_rewards[i].rarity > max_rarity) {
            max_rarity = _rewards[i].rarity;
        }
    }
    
    // Map rarity to shake: 0=3, 1=6, 2=10, 3=15
    return 3 + (max_rarity * 4);
}

function HasBombMod(_player) {
    // Check if player has the bomb trap mod
    for (var i = 0; i < array_length(_player.mod_list); i++) {
        var mod_inst = _player.mod_list[i];
        if (mod_inst.template_key == "ChestBomber") { // You'll create this mod
            return true;
        }
    }
    return false;
}

function CalculateBombDamage(_rewards) {
    // Calculate damage based on rarity count
    var base_damage = 50;
    var rarity_total = 0;
    
    for (var i = 0; i < array_length(_rewards); i++) {
        rarity_total += _rewards[i].rarity;
    }
    
    // More rare rewards = bigger boom
    return base_damage * (1 + rarity_total * 0.5);
}