// --- Clean Up Event ---
ds_list_destroy(hitList);
if (instance_exists(owner)) {
    owner.sword = noone;
}