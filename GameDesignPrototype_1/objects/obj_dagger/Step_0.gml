/// obj_dagger Step Event
event_inherited();

// Reset lunge flag after swing completes
if (!swinging) {
    is_lunging = false;
}
