/// @description obj_tutorial_controller - Create Event

enum TUTORIAL_PHASE {
    INTRO_TEXT,
    GO_TO_FRIEND,
    THROW_BALL,
    THROW_RETRY,
    PICKUP_BAT,
    BAT_BALL,
    DEFLECT_PRACTICE,
    COMPLETE
}

phase = TUTORIAL_PHASE.INTRO_TEXT;

// References - SET THESE IN ROOM CREATION CODE or find them
friend_npc = noone;

// Tracking
throws_missed = 0;
deflect_attempts = 0;
deflection_success = false;

// Transition
flash_alpha = 0;
transition_room = rm_demo_room;

// Indicator
indicator_target = noone;
indicator_visible = false;

// Dialogue cooldown
dialogue_cooldown = 0;

// Player wander tracking
wander_timer = 0;

// Init after room loads
alarm[0] = 2;


