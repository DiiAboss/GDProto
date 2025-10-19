/// @description
// General dash enemy variables
state           = "idle";
dashTargetX     = x;
dashTargetY     = y;
dashDistance    = 10;      // How far it dashes each attack
dashSpeed       = 6;        // Dash speed
dashCooldown    = 90;       // Frames to wait between dashes
dashTimer       = irandom_range(15, dashCooldown);
canBeHit        = true;

// For telegraph
showIndicator   = false;
indicatorLength = 20;       // Length of the line
indicatorColor  = c_red;

event_inherited();

can_attack = true;

bomb_timer = 180;