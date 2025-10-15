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
	HIT = 3,
	JUMPING = 4, 
}


enum PlayerClass {
    RANGER,
    MELEE
}


enum ChestState {
    IDLE = 0,
    CHOICE_PROMPT = 1,
    ACTIVATING = 2,
    MOVING_CENTER = 3,
    BURSTING = 4,
    SHOWING_REWARDS = 5,
    CLOSING = 6
}

enum ChestType {
    MINI = 0,        // 1 random item
    GOLD = 1,        // 3 random items, free
    PREMIUM = 2      // Scaling cost, guaranteed rare, 3+ items
}

enum RewardType {
    MODIFIER = 0,
    WEAPON = 1,
    ITEM = 2
}

enum TotemType {
    CHAOS = 0,      // Spawns rolling balls
    HORDE = 1,      // Increased enemy spawn rate
    CHAMPION = 2,   // Spawns mini-bosses
    GREED = 3,      // More gold drops, tougher enemies
    FURY = 4        // Faster/stronger enemies, XP multiplier
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