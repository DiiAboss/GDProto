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
	Holy_Water = 6,
	ThrowableItem = 7,
	ChainWhip = 8,
	Axe,
	Staff,
	Whip,
	Spear
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


// Position states (YOUR SYSTEM)
enum SwingPosition {
    Down = 0,
    Up = 1
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
    CLOSING = 6,
	OPENING = 7,
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


// Weapon categories for synergy system
enum WeaponCategory {
    SWORD,
    BAT,
    DAGGER,
    GRENADE,
    BOW,
    CANNON,
    BOOMERANG
}

// Character archetypes for synergy system
enum CharacterArchetype {
    WARRIOR,
    MAGE,
    BASEBALL_PLAYER,
    VAMPIRE,
    ROGUE
}

// Synergy types - what actually happens
enum SynergyType {
    NONE,
    
    // Mage synergies
    SPELL_BASEBALL,         // Mage + Bat: Spawns magic baseballs on swing
    ARCANE_BLADE,           // Mage + Sword: Reduced stats but shoots magic on slash
    HOLY_GRENADE,           // Mage + Grenade: Holy water explosion
    
    // Baseball player synergies
    HOMERUN_MASTER,         // Baseball + Bat: Massive homerun chance increase
    FASTBALL_THROW,         // Baseball + Grenade: Throws like fastball, faster
    
    // Warrior synergies
    BRUTAL_SWING,           // Warrior + Bat: Extra damage, slower
    RAGE_BLADE,             // Warrior + Sword: Rage boost on hit
    
    // Vampire synergies
    BLOOD_BAT,              // Vampire + Bat: Lifesteal on hit
    CRIMSON_BLADE,          // Vampire + Sword: Blood trail projectiles
    
    // Can add more as needed
}

// Projectile spawning behavior for synergies
enum SynergyProjectileBehavior {
    NONE,
    ON_SWING,               // Spawn projectile during each swing
    ON_HIT,                 // Spawn projectile when weapon hits enemy
    ON_COMBO_FINISH,        // Spawn on final combo hit only
    REPLACE_ATTACK,         // Don't swing, just shoot projectile
    THROW_STYLE             // Change grenade throw behavior
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