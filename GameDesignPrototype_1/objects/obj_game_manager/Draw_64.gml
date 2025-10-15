// Draw level-up popup
if (variable_global_exists("selection_popup") && global.selection_popup != undefined) {
    global.selection_popup.draw();
}

// Draw chest popup
if (variable_global_exists("chest_popup") && global.chest_popup != undefined) {
    global.chest_popup.draw();
}