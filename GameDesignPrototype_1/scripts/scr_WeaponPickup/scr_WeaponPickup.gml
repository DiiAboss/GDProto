/// @function SpawnWeaponPickup(_x, _y, _weapon_struct)
function SpawnWeaponPickup(_x, _y, _weapon_struct) {
    var pickup = instance_create_depth(_x, _y, 0, obj_weapon_pickup);
    
    pickup.weapon_data = _weapon_struct;
    pickup.weapon_name = _weapon_struct.name;
    
    // Set sprite based on weapon
    switch (_weapon_struct.id) {
        case Weapon.Sword:
            pickup.weapon_sprite = spr_sword;
            break;
        case Weapon.Dagger:
            pickup.weapon_sprite = spr_dagger;
            break;
        case Weapon.Bow:
            pickup.weapon_sprite = spr_crossbow;
            break;
        case Weapon.ChainWhip:
            pickup.weapon_sprite = spr_chain_link;
            break;
        case Weapon.BaseballBat:
            pickup.weapon_sprite = spr_bat;
            break;
        case Weapon.Boomerang:
            pickup.weapon_sprite = spr_boomerang;
            break;
        case Weapon.Holy_Water:
            pickup.weapon_sprite = spr_holy_water;
            break;
        default:
            pickup.weapon_sprite = spr_knife;
            break;
    }
    
    return pickup;
}