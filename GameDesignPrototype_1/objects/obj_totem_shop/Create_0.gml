/// @description
/// @desc Totem shop - purchase interface

interact_range = 80;
interactable = true;

// Available totems (show all 5)
available_totems = [
    TotemType.CHAOS,
    TotemType.HORDE,
    TotemType.CHAMPION,
    TotemType.GREED,
    TotemType.FURY
];

// UI state
show_menu = false;
selected_index = 0;

// Visual
glow_alpha = 0.5;
glow_timer = 0;

depth = -y;