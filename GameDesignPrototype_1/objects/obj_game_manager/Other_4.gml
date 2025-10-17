/// @description
OnRoomStart(DetermineRoomType(room));


if (room == rm_demo_room)
{
	audio_play_sound(Sound2, 1, 1);
	
/// @description Debug Sprite Loading

// ==========================================
// OPTION 1: Add to obj_game_manager Create Event
// ==========================================

show_debug_message("=== TESTING MODIFIER SPRITES ===");

// Test each modifier
var test_mods = [
    "TripleRhythmFire",
    "SpreadFire", 
    "DoubleLightning",
    "ChainLightning",
    "MultiShot"
];

for (var i = 0; i < array_length(test_mods); i++) {
    var mod_key = test_mods[i];
    var sprite_name = "spr_mod_" + mod_key;
    
    show_debug_message("Looking for: " + sprite_name);
    
    var sprite_asset = asset_get_index(sprite_name);
    show_debug_message("  asset_get_index returned: " + string(sprite_asset));
    
    if (sprite_exists(sprite_asset)) {
        show_debug_message("  ✓ SPRITE EXISTS!");
    } else {
        show_debug_message("  ✗ SPRITE NOT FOUND");
        
        // Try alternate name
        var alt_name = "spr_mod_" + string_lower(mod_key);
        show_debug_message("  Trying lowercase: " + alt_name);
        var alt_asset = asset_get_index(alt_name);
        if (sprite_exists(alt_asset)) {
            show_debug_message("  ✓ FOUND WITH LOWERCASE!");
        }
    }
}

// Check default sprite
show_debug_message("Checking default sprite...");
if (sprite_exists(spr_mod_default)) {
    show_debug_message("  ✓ spr_mod_default EXISTS");
} else {
    show_debug_message("  ✗ spr_mod_default NOT FOUND");
}

// Check fallback
show_debug_message("Checking fallback sprite...");

show_debug_message("=== END SPRITE TEST ===");

// ==========================================
// OPTION 2: Update GetModifierSprite with debug
// ==========================================

/// @function GetModifierSprite(_mod_key)
function GetModifierSprite(_mod_key) {
    show_debug_message("GetModifierSprite called for: " + _mod_key);
    
    // Build sprite name
    var sprite_name = "spr_mod_" + _mod_key;
    show_debug_message("  Looking for sprite: " + sprite_name);
    
    var sprite_asset = asset_get_index(sprite_name);
    show_debug_message("  asset_get_index returned: " + string(sprite_asset));
    
    // Check if sprite exists
    if (sprite_exists(sprite_asset)) {
        show_debug_message("  ✓ Using sprite: " + sprite_name);
        return sprite_asset;
    }
    
    

        show_debug_message("  ✓ Using spr_mod_default");
        return spr_mod_default;

}

// ==========================================
// OPTION 3: List ALL sprites in project
// ==========================================

show_debug_message("=== ALL SPRITES IN PROJECT ===");
var sprite_count = 0;

// Check if any spr_mod_ sprites exist
for (var i = 0; i < 10000; i++) {
    if (sprite_exists(i)) {
        var spr_name = sprite_get_name(i);
        
        // Only show mod sprites
        if (string_pos("spr_mod_", spr_name) > 0) {
            show_debug_message("Found: " + spr_name);
            sprite_count++;
        }
    }
}

show_debug_message("Total mod sprites found: " + string(sprite_count));
show_debug_message("=== END SPRITE LIST ===");
	
}