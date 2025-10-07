
projectileType = PROJECTILE_TYPE.NORMAL;

myDir = 0;
img_xscale = 1;
speed = 8;

life = 100;
active = true;

damage = 10;
piercing = false;


// Drawing
sprite = sprite_index;
img    = -1;
color  = c_white;

lobbed = false;

startTime = current_time; // Track when the bullet was fired
xStart = x;
yStart = y;
progress = 0; // Start at the beginning of the arc
oval_width = 320; // Half the total width of the oval
oval_height = 160; // Half the total height of the oval
radDirection = degtorad(direction);

targetDistance = 0;
lobStep = 0;
owner = noone;

// Define the arc's peak height above the midpoint
//arcHeight = 50; // Adjust the height as needed
shadowSprite = spr_orb;

drawDirection = direction;

targetX = 0;
targetY = 0;
groundShadowY = 0;

can_trigger_modifiers = true;  // Default to true, set to false if needed