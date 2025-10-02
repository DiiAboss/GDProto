enum Weapon
{
	None = -1,
	Sword = 0,
	Bow = 1,
}

enum CONTROL_TYPE
{
    KBM,
    LAPTOP,
    GAMEPAD
}



enum ENEMY_STATE
{
	IDLE = 0,
	FOLLOW = 1,
	ATTACK = 2,
	HIT = 3
}


	// Directional MACROS
	#macro NORTH 90
	#macro WEST 180
	#macro SOUTH 270
	#macro EAST 0
	#macro NORTHEAST 45
	#macro NORTHWEST 135
	#macro SOUTHWEST 225
	#macro SOUTHEAST 315