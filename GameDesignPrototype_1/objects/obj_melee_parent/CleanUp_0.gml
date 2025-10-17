/// @description Clean Up
ds_list_destroy(hitList);
if (instance_exists(owner)) {
    owner.melee_weapon = noone;
}