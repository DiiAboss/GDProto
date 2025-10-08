enum WeaponType {
    None = -1,
    Melee = 0,
    Range = 1
}

enum Weapon {
    None = -1,
    Sword = 0,
    Bow = 1,
    Dagger = 2,
    Boomerang = 3,
    ChargeCannon = 4,
	BaseballBat = 5,
}

enum AttackType {
    UNKNOWN = 0,
    MELEE = 1,
    RANGED = 2,
    CANNON = 3,
    BOOMERANG = 4
}

enum ComboState {
    IDLE = 0,
    LIGHT_1 = 1,
    LIGHT_2 = 2,
    LIGHT_3 = 3,
    HEAVY_1 = 4,
    HEAVY_FINISHER = 5
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