/// @description
// Update visual timers
if (bloodTimer > 0) {
    bloodTimer--;
}

if (shake > 0) {
    shake *= 0.8; // Decay shake
    if (shake < 0.1) shake = 0;
}

// Clean up hit list (remove enemies that left or have cooled down)
for (var i = ds_list_size(hitList) - 1; i >= 0; i--) {
    var hitData = hitList[| i];
    var enemy = hitData[0];
    var timer = hitData[1] - 1;
    
    if (!instance_exists(enemy) || timer <= 0) {
        ds_list_delete(hitList, i);
    } else {
        hitData[1] = timer;
        hitList[| i] = hitData;
    }
}

// Reset sound flag
playedSound = false;
