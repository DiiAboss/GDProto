/// @desc Centralized game speed system
/// All time-dependent values should use these functions

/// @function game_speed_delta()
/// @desc Returns the current game speed multiplier
/// @returns {real}
function game_speed_delta() {
    return global.gameSpeed;
}

/// @function timer_tick(_timer)
/// @desc Decrements a timer by game speed
/// @param _timer Current timer value
/// @returns {real} Updated timer value
function timer_tick(_timer) {
    if (_timer <= 0) return 0;
    return max(0, _timer - game_speed_delta());
}

/// @function scale_animation(_base_speed)
/// @desc Scales animation speed by game speed
/// @param _base_speed Base image_speed value
/// @returns {real} Scaled speed
function scale_animation(_base_speed) {
    return _base_speed * game_speed_delta();
}

/// @function scale_movement(_base_speed)
/// @desc Scales movement speed by game speed
/// @param _base_speed Base movement speed
/// @returns {real} Scaled speed
function scale_movement(_base_speed) {
    return _base_speed * game_speed_delta();
}