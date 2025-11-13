// Script Created By DiiAboss AKA Dillon Abotossaway

enum BUTTON_TYPE
{
	NONE,
	MOUSE,
	KEYBOARD,
	GAMEPAD
}

function Input() constructor
{
	ID				= -1;
	Name			= "";
	InputMap		= global.InputType.cKeyboard;
	ControllerMap   = global.InputType.cGamepad;
	Device			= -1;
	InputType		= INPUT.KEYBOARD;
	
	ButtonHold = 10;
	
	Up		  = false;
	Left	  = false;
	Down	  = false;
	Right	  = false;
	
	
    UpPress = false;
    LeftPress = false;
    DownPress = false;
    RightPress = false;
	
	FireButtonType = BUTTON_TYPE.MOUSE;
	Fire	  = false;
	FirePress = false;
	
	AltButtonType = BUTTON_TYPE.MOUSE;
	Alt		  = false;
	AltPress  = false;
	AltHold = mouse_check_button(mb_right);
	AltRelease = mouse_check_button_released(mb_right);
	
	Action    = false;
	Back      = false;
	Reload	  = false;
	
	Direction = 0;
	
	
	for (var cont = 0; cont < 8; cont++)
	{
		if (gamepad_is_connected(cont))
		{
			Device = cont;
			break;
		}
	}
	
	static GetDevicePrompt = function(_action) {
        if (InputType == INPUT.KEYBOARD) {
            switch(_action) {
                case "confirm": return "[ENTER]";
                case "back": return "[ESC]";
                case "navigate": return "[WASD/ARROWS]";
                case "interact": return "[E]";
                case "attack": return "[LMB]";
                case "special": return "[RMB]";
                default: return "";
            }
        } else {
            // Gamepad prompts (Xbox style)
            switch(_action) {
                case "confirm": return "(A)";
                case "back": return "(B)";
                case "navigate": return "(D-PAD/STICK)";
                case "interact": return "(X)";
                case "attack": return "(RT)";
                case "special": return "(LT)";
                default: return "";
            }
        }
    }
	
	static Update = function(_self)
	{
		 // AUTO-DETECT DEVICE SWITCHING
	    // Check for keyboard activity when in gamepad mode
	    if (InputType == INPUT.GAMEPAD && keyboard_check(vk_anykey)) {
	        InputType = INPUT.KEYBOARD;
	    }
	    
	    // Check for gamepad activity when in keyboard mode
	    if (InputType == INPUT.KEYBOARD && Device != -1) {
	        // Check any gamepad button
	        for (var i = gp_face1; i <= gp_padr; i++) {
	            if (gamepad_button_check(Device, i)) {
	                InputType = INPUT.GAMEPAD;
	                break;
	            }
	        }
	        
	        // Check analog sticks (with deadzone)
	        if (abs(gamepad_axis_value(Device, gp_axislh)) > 0.3 ||
	            abs(gamepad_axis_value(Device, gp_axislv)) > 0.3) {
	            InputType = INPUT.GAMEPAD;
	        }
	    }
		if (InputType == INPUT.KEYBOARD)
		{
			Up		= keyboard_check(InputMap.Up);
			Left	= keyboard_check(InputMap.Left);
			Right	= keyboard_check(InputMap.Right);
			Down	= keyboard_check(InputMap.Down);
			
			UpPress		 = keyboard_check_pressed(vk_up) || keyboard_check_pressed(InputMap.Up);
			LeftPress	 = keyboard_check_pressed(vk_left) || keyboard_check_pressed(InputMap.Left);
			RightPress	 = keyboard_check_pressed(vk_right) || keyboard_check_pressed(InputMap.Right);
			DownPress	 = keyboard_check_pressed(vk_down) || keyboard_check_pressed(InputMap.Down);
			
			Action	= keyboard_check_pressed(InputMap.Action);
			Back    = keyboard_check_pressed(InputMap.Back);
			Reload  = keyboard_check_pressed(InputMap.Reload);
			
			SwapUp   = mouse_wheel_up();
			SwapDown = mouse_wheel_down();
			
			Fire		= mouse_check_button(InputMap.Fire);
			FirePress	= mouse_check_button_pressed(InputMap.Fire);
			FireRelease = mouse_check_button_released(InputMap.Fire);
			
			Alt			= mouse_check_button(InputMap.Alt);
			AltPress	= mouse_check_button_pressed(InputMap.Alt);
			AltRelease  = mouse_check_button_released(InputMap.Alt)
			
			OpenInv     = keyboard_check_pressed(InputMap.OpenInv);
			
			Escape		= keyboard_check_pressed(InputMap.Escape);
			
			Direction   = point_direction(_self.x, _self.y, mouse_x, mouse_y);

			if (Device != -1)
			{
				if (gamepad_button_check(Device, ControllerMap.Enter))
				{
					InputType = INPUT.GAMEPAD;
					
				}
			}
			
		}
		
		if (InputType == INPUT.GAMEPAD)
		{
			Up =    gamepad_button_check(Device, ControllerMap.Up)    || (gamepad_axis_value(Device, gp_axislv) < -0.5);
			Left =  gamepad_button_check(Device, ControllerMap.Left)  || (gamepad_axis_value(Device, gp_axislh) < -0.5);
			Right = gamepad_button_check(Device, ControllerMap.Right) || (gamepad_axis_value(Device, gp_axislh) > 0.5);
			Down =  gamepad_button_check(Device, ControllerMap.Down)  || (gamepad_axis_value(Device, gp_axislv) > 0.5);
			
			UpPress		 = gamepad_button_check_pressed(Device, ControllerMap.Up)    || ((gamepad_axis_value(Device, gp_axislv) < -0.5) && ButtonHold = 10);
			LeftPress	 = gamepad_button_check_pressed(Device, ControllerMap.Left)  || ((gamepad_axis_value(Device, gp_axislh) < -0.5) && ButtonHold = 10);
			RightPress	 = gamepad_button_check_pressed(Device, ControllerMap.Right) || ((gamepad_axis_value(Device, gp_axislh) > 0.5) && ButtonHold = 10);
			DownPress	 = gamepad_button_check_pressed(Device, ControllerMap.Down)  || ((gamepad_axis_value(Device, gp_axislv) > 0.5) && ButtonHold = 10);
			
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
			
			
			Action		= gamepad_button_check_pressed(Device, ControllerMap.Action);
			Back		= gamepad_button_check_pressed(Device, ControllerMap.Back);
			Reload		= gamepad_button_check_pressed(Device, ControllerMap.Reload);
			
			SwapUp		= gamepad_button_check_pressed(Device, ControllerMap.SwapUp);
			SwapDown	= false;
			
			Fire		= gamepad_button_check(Device, ControllerMap.Fire);
			FirePress	= gamepad_button_check_pressed(Device, ControllerMap.Fire);
			FireRelease = gamepad_button_check_released(Device, ControllerMap.Fire);
			
			Alt			= gamepad_button_check(Device, ControllerMap.Alt);
			AltPress	= gamepad_button_check_pressed(Device, ControllerMap.Alt);
			AltRelease  = gamepad_button_check_released(Device, ControllerMap.Alt);
			
			OpenInv     = gamepad_button_check_pressed(Device, ControllerMap.OpenInv);
			
			Escape      = gamepad_button_check_pressed(Device, ControllerMap.Escape);
			
			var rhAxis = gamepad_axis_value(Device, gp_axisrh);
			var rvAxis = gamepad_axis_value(Device, gp_axisrv);
			
			
			Direction   = point_direction(_self.x, _self.y, _self.x + rhAxis, _self.y + rvAxis);

			if (keyboard_check_pressed(vk_anykey))
			{
				InputType = INPUT.KEYBOARD;
			}
		}
	}
	

	static Initialize = function()
	{
		Name	= InputMap.Name;
		ID		= InputMap.ID;
		
	}
}

enum INPUT
{
	NONE,
	KEYBOARD,
	GAMEPAD
}
global.InputType =
{
	cKeyboard: 
	{
		ID:    INPUT.KEYBOARD,
		Name:  "Keyboard",
	
		Up:			ord("W"),
		Left:		ord("A"),
		Down:		ord("S"),
		Right:		ord("D"),
	
	
		Fire:		mb_left,
		FirePress:  mb_left,
		Alt:		mb_right,
		AltPress:   mb_right,
	
		Action:		vk_space,
		Back:		ord("F"),
		Reload:		ord("R"),
		SwapDown:	-1,
		SwapUp:     -1,
		
		Escape:		vk_escape,
		Enter:      vk_enter,
		

		OpenInv:	ord("I")
	},

	cGamepad:
	{
		ID: INPUT.GAMEPAD,
		Name: "Controller",
	
		Up:			gp_padu,
		Left:		gp_padl,
		Down:		gp_padd,
		Right:		gp_padr,
	
	
		Fire:		gp_shoulderrb,
		FirePress:  gp_shoulderrb,
		Alt:		gp_shoulderlb,
		AltPress:   gp_shoulderlb,
	
		Action:		gp_face1,
		Back:		gp_face2,
		Reload:		gp_face3,
		SwapUp:		gp_face4,
		SwapDown:   -1,
		
		Escape:		gp_start,
		Enter:      gp_start,
		
		OpenInv:	gp_select

	}
}