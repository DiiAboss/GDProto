global.Player_Class = 
{
	Warrior:
	{
		type: CharacterClass.WARRIOR,
        name: "WARRIOR",
        desc: "High damage\nRage builds",
        color: c_red,
		sprite: spr_vh_walk_south,
		portrait: spr_Baseball_Bg,
	},
	Holy_Mage:
	{
		type: CharacterClass.HOLY_MAGE, 
        name: "HOLY MAGE",
        desc: "Projectiles\nArea control",
        color: c_aqua,
		sprite: spr_vh_walk_south,
		portrait: spr_Baseball_Bg,
	},
	Vampire:
	{
		type: CharacterClass.VAMPIRE,
        name: "VAMPIRE",
        desc: "Lifesteal\nHigh mobility",
        color: c_purple,
		sprite: spr_vh_walk_south,
		portrait: spr_Baseball_Bg,
	}
}

/// @function GetSelectedCharacterClass()
/// @description Get the currently selected character class
function GetSelectedCharacterClass(_main_controller) {
    return _main_controller.menu_system.selected_character_class;
}