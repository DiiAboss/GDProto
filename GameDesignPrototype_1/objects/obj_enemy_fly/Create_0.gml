event_inherited();

// --- State setup ---
state         = ENEMY_STATE.IDLE;
target        = obj_player;

// --- Jump logic ---
jumpStartX    = x;
jumpStartY    = y;
jumpTargetX   = x;
jumpTargetY   = y;
jumpDistance  = 160; // distance per hop
jumpSpeed     = 4;  // movement rate inside Jump()
jumpCooldown  = irandom_range(45, 60);
jumpTimer     = 0;
jumping       = false;
canBeHit      = true;
moveSpeed     = 0;
jumpHeight    = 24;
jumpProgress = 0;


squashTimer   = 0;   // For smoothing the squash/stretch effect
squashSpeed   = 0.15; // How quickly the blob squashes/returns
squashAmount  = 0.2;  // Max scale change
xScaleTarget  = 1;
yScaleTarget  = 1;
