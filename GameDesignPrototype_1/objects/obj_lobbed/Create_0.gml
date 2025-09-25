life = 32;

// Drawing
sprite = sprite_index;
img    = -1;
color  = c_white;

lobbed = true;

startTime = current_time; // Track when the bullet was fired
xStart = x;
yStart = y;
progress = 0; // Start at the beginning of the arc
speed = 0.02; // Speed of the bullet along the arc, adjust as needed
oval_width = 320; // Half the total width of the oval
oval_height = 160; // Half the total height of the oval
radDirection = degtorad(direction);
outlineX = xStart + oval_width * cos(radDirection);
outlineY = yStart - oval_height * sin(radDirection); // Note the minus sign to adjust for GameMaker's coordinate system
targetDistance = 0;
lobStep = 0;
owner = noone;

// Define the arc's peak height above the midpoint
arcHeight = 50; // Adjust the height as needed

shadowSprite = spr_orb;

// In the Create Event or where you initialize variables
maxJumpHeight = 200; // Adjust this value as needed
shadowSize = 1;