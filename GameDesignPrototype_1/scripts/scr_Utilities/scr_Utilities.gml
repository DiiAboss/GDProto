/// @function struct_get_safe(_struct, _key, _default)
/// @desc Safely get struct value with default (replaces variable_struct_exists pattern)
function struct_get_safe(_struct, _key, _default = undefined) {
    if (!is_struct(_struct)) return _default;
    if (!variable_struct_exists(_struct, _key)) return _default;
    return _struct[$ _key];
}

/// @function instance_get_safe(_inst, _var, _default)
/// @desc Safely get instance variable with default
function instance_get_safe(_inst, _var, _default = undefined) {
    if (!instance_exists(_inst)) return _default;
    if (!variable_instance_exists(_inst, _var)) return _default;
    return variable_instance_get(_inst, _var);
}

/// @function array_shuffle(_array)
/// @desc Fisher-Yates shuffle (you use this pattern multiple times)
function array_shuffle(_array) {
    var n = array_length(_array);
    for (var i = n - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = _array[i];
        _array[i] = _array[j];
        _array[j] = temp;
    }
    return _array;
}

/// @function clamp_wrap(_value, _min, _max)
/// @desc Wrap value around range (for menu navigation)
function clamp_wrap(_value, _min, _max) {
    var range = _max - _min + 1;
    return (((_value - _min) mod range) + range) mod range + _min;
}