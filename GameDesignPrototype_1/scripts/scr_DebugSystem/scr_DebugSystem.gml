/// @desc Centralized debug system with production toggle

// MASTER TOGGLE - Set to false for production builds
#macro DEBUG_MODE true
#macro DEBUG_VERBOSE false

/// @function debug_log(_message, [_category])
/// @desc Only logs if DEBUG_MODE is true
function debug_log(_message, _category = "GENERAL") {
    if (!DEBUG_MODE) return;
    show_debug_message("[" + _category + "] " + string(_message));
}

/// @function debug_verbose(_message, [_category])
/// @desc Only logs if DEBUG_VERBOSE is true (detailed logs)
function debug_verbose(_message, _category = "VERBOSE") {
    if (!DEBUG_VERBOSE) return;
    show_debug_message("[" + _category + "] " + string(_message));
}

/// @function debug_error(_message)
/// @desc Always logs errors, even in production
function debug_error(_message) {
    show_debug_message("[ERROR] " + string(_message));
}

/// @function debug_warning(_message)
/// @desc Logs warnings if DEBUG_MODE is true
function debug_warning(_message) {
    if (!DEBUG_MODE) return;
    show_debug_message("[WARNING] " + string(_message));
}