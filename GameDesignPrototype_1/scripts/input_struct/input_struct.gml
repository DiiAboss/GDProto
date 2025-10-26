// Script Created By DiiAboss AKA Dillon Abotossaway
// Documented by xuckless AKA Syed Ali

/// ------------------------------------------------------------
/// Module: Input.gml
/// Purpose: Centralized input abstraction for keyboard/mouse and gamepad,
///          with hot‑swap detection, directional repeat timing, and unified
///          action mapping used across the game (movement, fire/alt, UI).
/// Design notes:
///  - Input() constructor holds per‑player state and the active device.
///  - static Update(self) samples hardware each step and updates state,
///    auto‑switching INPUT type based on last interaction.
///  - static Initialize() pulls the configured map (ID/Name) into instance.
///  - ButtonHold acts as a simple repeat‑delay for analog stick/DPAD navigation
///    (e.g., menus or grid moves) so held directions don’t spam.
///  - Direction is the player’s facing/aim angle. For mouse: to mouse cursor;
///    for gamepad: right stick vector.
///  - Fire/Alt support both press and release semantics for gameplay logic.
///  - Input maps live in global.InputType (keyboard / gamepad), allowing
///    rebinding or additional device profiles without touching Update logic.
/// Caveats flagged (not changed):
///  - Gamepad *Press checks combine an axis threshold with `ButtonHold = 10`.
///    That uses assignment, not comparison; likely a bug (intended `== 10`).
///  - Keyboard AltRelease line misses a semicolon.
///  - AltHold/AltRelease are initialized to mouse state outside Update; these
///    are re‑assigned in Update each step; the constructor init is redundant.
///  - FireButtonType/AltButtonType exist gbut aren’t used downstream.
/// ------------------------------------------------------------

/// Button source classification for downstream UI/tooling (currently not used
/// by Update; kept for higher‑level systems that may query input origin).
enum BUTTON_TYPE
{
    NONE,
    MOUSE,
    KEYBOARD,
    GAMEPAD
}

/// ------------------------------------------------------------
/// class Input
/// Role in the system:
///  - One instance per controllable actor or player slot.
///  - Acts as the single source of truth for that actor’s controls.
///  - Higher‑level gameplay (movement, shooting, UI) reads these booleans
///    and angles without caring about the physical device.
///  - Supports hot‑swapping: last used device (enter/start vs any key) flips
///    InputType, so menus/gameplay adapt seamlessly.
/// ------------------------------------------------------------
function Input() constructor
{
    // Identity & mapping ---------------------------
    ID              = -1;                // Active input map ID (from global.InputType)
    Name            = "";                // Human‑readable profile name
    InputMap        = global.InputType.cKeyboard;   // Current logical map in use
    ControllerMap   = global.InputType.cGamepad;    // Secondary map for gamepad
    Device          = -1;                // Gamepad index (0..7), -1 if none
    InputType       = INPUT.KEYBOARD;    // Active device class (hot‑swapped)

    // Directional repeat pacing for held DPAD/analog in menus or grid games
    ButtonHold = 10;                     // Countdown; when 0, re‑fire a press

    // Movement state -------------------------------
    Up        = false;
    Left      = false;
    Down      = false;
    Right     = false;

    // Primary fire --------------------------------
    FireButtonType = BUTTON_TYPE.MOUSE;  // Declares source class (not enforced)
    Fire      = false;                   // Held state
    FirePress = false;                   // Edge: pressed this step

    // Alternate fire / ability ---------------------
    AltButtonType = BUTTON_TYPE.MOUSE;   // Declares source class (not enforced)
    Alt       = false;
    AltPress  = false;
    AltHold   = mouse_check_button(mb_right);               // Redundant init; Update overrides
    AltRelease= mouse_check_button_released(mb_right);      // Redundant init; Update overrides

    // Other actions --------------------------------
    Action    = false;
    Back      = false;
    Reload    = false;

    // Aiming/facing --------------------------------
    Direction = 0;                        // Degrees; mouse or right‑stick derived

    // Probe for first connected gamepad (allows immediate hot‑swap later)
    for (var cont = 0; cont < 8; cont++)
    {
        if (gamepad_is_connected(cont))
        {
            Device = cont;
            break;
        }
    }

    /// --------------------------------------------------------
    /// Update(self)
    /// Reads hardware for current InputType, updates all states,
    /// computes Direction, and hot‑swaps device type based on user
    /// activity (Start/Enter vs AnyKey). Also implements ButtonHold
    /// based repeat timing for directional inputs on gamepad.
    /// Call: once per Step (Begin/End as appropriate for your project).
    /// --------------------------------------------------------
    static Update = function(_self)
    {
        if (InputType == INPUT.KEYBOARD)
        {
            // Movement from keyboard map (WASD by default)
            Up      = keyboard_check(InputMap.Up);
            Left    = keyboard_check(InputMap.Left);
            Right   = keyboard_check(InputMap.Right);
            Down    = keyboard_check(InputMap.Down);

            // Arrow key single‑press edges (e.g., menu navigation)
            UpPress     = keyboard_check_pressed(vk_up);
            LeftPress   = keyboard_check_pressed(vk_left);
            RightPress  = keyboard_check_pressed(vk_right);
            DownPress   = keyboard_check_pressed(vk_down);

            // Discrete gameplay actions
            Action  = keyboard_check_pressed(InputMap.Action);
            Back    = keyboard_check_pressed(InputMap.Back);
            Reload  = keyboard_check_pressed(InputMap.Reload);

            // Weapon swap via mouse wheel
            SwapUp   = mouse_wheel_up();
            SwapDown = mouse_wheel_down();

            // Mouse buttons for fire/alt (held + edge + release)
            Fire        = mouse_check_button(InputMap.Fire);
            FirePress   = mouse_check_button_pressed(InputMap.Fire);
            FireRelease = mouse_check_button_released(InputMap.Fire);

            Alt         = mouse_check_button(InputMap.Alt);
            AltPress    = mouse_check_button_pressed(InputMap.Alt);
            AltRelease  = mouse_check_button_released(InputMap.Alt) // NOTE: missing semicolon in original

            // Inventory/UI and meta
            OpenInv     = keyboard_check_pressed(InputMap.OpenInv);
            Escape      = keyboard_check_pressed(InputMap.Escape);

            // Aim toward mouse cursor
            Direction   = point_direction(_self.x, _self.y, mouse_x, mouse_y);

            // If a gamepad is connected and user hits Start/Enter on it, swap
            if (Device != -1)
            {
                if (gamepad_button_check(Device, ControllerMap.Enter))
                {
                    InputType = INPUT.GAMEPAD; // Hot‑swap
                }
            }
        }

        if (InputType == INPUT.GAMEPAD)
        {
            // Movement accepts DPAD OR left‑stick threshold
            Up    =  gamepad_button_check(Device, ControllerMap.Up)    || (gamepad_axis_value(Device, gp_axislv) < -0.5);
            Left  =  gamepad_button_check(Device, ControllerMap.Left)  || (gamepad_axis_value(Device, gp_axislh) < -0.5);
            Right =  gamepad_button_check(Device, ControllerMap.Right) || (gamepad_axis_value(Device, gp_axislh) >  0.5);
            Down  =  gamepad_button_check(Device, ControllerMap.Down)  || (gamepad_axis_value(Device, gp_axislv) >  0.5);

            // Edge detection with simple repeat gating via ButtonHold.
            // NOTE: uses assignment (= 10) not comparison; likely a logic bug.
            UpPress     = gamepad_button_check_pressed(Device, ControllerMap.Up)    || ((gamepad_axis_value(Device, gp_axislv) < -0.5) && ButtonHold = 10);
            LeftPress   = gamepad_button_check_pressed(Device, ControllerMap.Left)  || ((gamepad_axis_value(Device, gp_axislh) < -0.5) && ButtonHold = 10);
            RightPress  = gamepad_button_check_pressed(Device, ControllerMap.Right) || ((gamepad_axis_value(Device, gp_axislh) >  0.5) && ButtonHold = 10);
            DownPress   = gamepad_button_check_pressed(Device, ControllerMap.Down)  || ((gamepad_axis_value(Device, gp_axislv) >  0.5) && ButtonHold = 10);

            // If any direction is held, count down; when it hits 0 we allow
            // another synthetic "press" and reset. Otherwise, reset when idle.
            if (Up)
            || (Left)
            || (Down)
            || (Right)
            {
                if (ButtonHold > 0) { ButtonHold -= global.gameSpeed; } else { ButtonHold = 10; }
            }
            else
            {
                ButtonHold = 10;
            }

            // Other actions (edge‑triggered)
            Action      = gamepad_button_check_pressed(Device, ControllerMap.Action);
            Back        = gamepad_button_check_pressed(Device, ControllerMap.Back);
            Reload      = gamepad_button_check_pressed(Device, ControllerMap.Reload);

            // Weapon swap (face button mapped; no SwapDown on pad by default)
            SwapUp      = gamepad_button_check_pressed(Device, ControllerMap.SwapUp);
            SwapDown    = false;

            // Fire/Alt (held + edges)
            Fire        = gamepad_button_check(Device, ControllerMap.Fire);
            FirePress   = gamepad_button_check_pressed(Device, ControllerMap.Fire);
            FireRelease = gamepad_button_check_released(Device, ControllerMap.Fire);

            Alt         = gamepad_button_check(Device, ControllerMap.Alt);
            AltPress    = gamepad_button_check_pressed(Device, ControllerMap.Alt);
            AltRelease  = gamepad_button_check_released(Device, ControllerMap.Alt);

            // Inventory/UI and meta
            OpenInv     = gamepad_button_check_pressed(Device, ControllerMap.OpenInv);
            Escape      = gamepad_button_check_pressed(Device, ControllerMap.Escape);

            // Right‑stick aiming: convert stick vector to world angle
            var rhAxis = gamepad_axis_value(Device, gp_axisrh);
            var rvAxis = gamepad_axis_value(Device, gp_axisrv);
            Direction   = point_direction(_self.x, _self.y, _self.x + rhAxis, _self.y + rvAxis);

            // Any keyboard press flips us back to keyboard mode (hot‑swap)
            if (keyboard_check_pressed(vk_anykey))
            {
                InputType = INPUT.KEYBOARD;
            }
        }
    }

    /// --------------------------------------------------------
    /// Initialize()
    /// Synchronizes instance ID/Name from the active InputMap. Use this
    /// after swapping InputMap profiles or on object creation.
    /// --------------------------------------------------------
    static Initialize = function()
    {
        Name = InputMap.Name;
        ID   = InputMap.ID;
    }
}

/// Device class for the abstraction above.
enum INPUT
{
    NONE,
    KEYBOARD,
    GAMEPAD
}

/// ------------------------------------------------------------
/// Global input maps
/// These define logical actions -> physical bindings for each profile.
/// Higher‑level code uses InputMap fields; Update reads from here.
/// Rebinds can be implemented by mutating these tables at runtime.
/// ------------------------------------------------------------
global.InputType = {
    cKeyboard: {
        ID:    INPUT.KEYBOARD,
        Name:  "Keyboard",

        // Movement (WASD)
        Up:    ord("W"),
        Left:  ord("A"),
        Down:  ord("S"),
        Right: ord("D"),

        // Mouse buttons
        Fire:      mb_left,
        FirePress: mb_left,
        Alt:       mb_right,
        AltPress:  mb_right,

        // Gameplay actions
        Action:   vk_space,
        Back:     ord("F"),
        Reload:   ord("R"),
        SwapDown: -1,
        SwapUp:   -1,
        
        // Meta / UI
        Escape: vk_escape,
        Enter:  vk_enter,
        OpenInv: ord("I")
    },

    cGamepad: {
        ID:   INPUT.GAMEPAD,
        Name: "Controller",

        // Movement (DPAD)
        Up:    gp_padu,
        Left:  gp_padl,
        Down:  gp_padd,
        Right: gp_padr,

        // Shoulder buttons for firing
        Fire:      gp_shoulderrb,
        FirePress: gp_shoulderrb,
        Alt:       gp_shoulderlb,
        AltPress:  gp_shoulderlb,

        // Face buttons for actions
        Action:  gp_face1,
        Back:    gp_face2,
        Reload:  gp_face3,
        SwapUp:  gp_face4,
        SwapDown: -1,
        
        // Meta / UI
        Escape: gp_start,
        Enter:  gp_start,
        OpenInv: gp_select
    }
};