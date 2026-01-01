switch(async_load[? "event_type"]){
	case "gamepad discovered":
		// Prevent a second gamepad from connecting to the game.
		if (global.gamepadID != -1)
			return;
	
		// Get the ID for the gamepad from the operating system. Then, see if the connected gamepad is one that
		// is supported by SDL (This is what Game Maker uses for input). If not, the gamepad can't be used.
		var _gamepadID = async_load[? "pad_index"];
		if (!gamepad_is_supported()) 
			return;
		
		// Set the gamepad's desired deadzones along its joystick(s) and the threshold for activation of the
		// its analog triggers. Then, store the reference to the input array so control icon info can be set 
		// for the newly connected gamepad.
		var _inputs = 0;
		with(global.settings){
			gamepad_set_axis_deadzone(_gamepadID, stickDeadzone);
			gamepad_set_button_threshold(_gamepadID, triggerThreshold);
			_inputs = inputs;
		}
		
		// Jump into scope of the control icon ui manager struct so all of the gamepad's matching input sprites
		// can be used whenever input information is shown to the player while the gamepad is active.
		with(CONTROL_UI_MANAGER){
			// Getting icon info for all in-game gamepad bindings.
			set_gamepad_control_icon(ICONUI_GAME_RIGHT,		_inputs[STNG_INPUT_GAME_RIGHT	+ 1]);
			set_gamepad_control_icon(ICONUI_GAME_LEFT,		_inputs[STNG_INPUT_GAME_LEFT	+ 1]);
			set_gamepad_control_icon(ICONUI_GAME_UP,		_inputs[STNG_INPUT_GAME_UP		+ 1]);
			set_gamepad_control_icon(ICONUI_GAME_DOWN,		_inputs[STNG_INPUT_GAME_DOWN	+ 1]);
			set_gamepad_control_icon(ICONUI_SPRINT,			_inputs[STNG_INPUT_SPRINT		+ 1]);
			set_gamepad_control_icon(ICONUI_INTERACT,		_inputs[STNG_INPUT_INTERACT		+ 1]);
			set_gamepad_control_icon(ICONUI_READYWEAPON,	_inputs[STNG_INPUT_READYWEAPON	+ 1]);
			set_gamepad_control_icon(ICONUI_FLASHLIGHT,		_inputs[STNG_INPUT_FLASHLIGHT	+ 1]);
			set_gamepad_control_icon(ICONUI_USEWEAPON,		_inputs[STNG_INPUT_USEWEAPON	+ 1]);
			
			// Getting icon info for inputs that are tied to opening/closing a given menu.
			set_gamepad_control_icon(ICONUI_ITEM_MENU,		_inputs[STNG_INPUT_ITEM_MENU	+ 1]);
			
			// Getting icon info for all generic menu-based gamepad bindings.
			set_gamepad_control_icon(ICONUI_MENU_RIGHT,		_inputs[STNG_INPUT_MENU_RIGHT	+ 1]);
			set_gamepad_control_icon(ICONUI_MENU_LEFT,		_inputs[STNG_INPUT_MENU_LEFT	+ 1]);
			set_gamepad_control_icon(ICONUI_MENU_UP,		_inputs[STNG_INPUT_MENU_UP		+ 1]);
			set_gamepad_control_icon(ICONUI_MENU_DOWN,		_inputs[STNG_INPUT_MENU_DOWN	+ 1]);
			set_gamepad_control_icon(ICONUI_SELECT,			_inputs[STNG_INPUT_SELECT		+ 1]);
			set_gamepad_control_icon(ICONUI_RETURN,			_inputs[STNG_INPUT_RETURN		+ 1]);
			
			// Getting icon info the textbox-specific gamepad bindings.
			set_gamepad_control_icon(ICONUI_TBOX_ADVANCE,	_inputs[STNG_INPUT_TBOX_ADVANCE	+ 1]);
			set_gamepad_control_icon(ICONUI_TBOX_LOG,		_inputs[STNG_INPUT_TBOX_LOG		+ 1]);
			
			// Getting icon info for the inventory menu-specific keyboard bindings.
			set_gamepad_control_icon(ICONUI_INV_LEFT,		_inputs[STNG_INPUT_INV_LEFT		+ 1]);
			set_gamepad_control_icon(ICONUI_INV_RIGHT,		_inputs[STNG_INPUT_INV_RIGHT	+ 1]);
		}
		
		// Store the gamepad's ID so input can be parsed with it later, but don't set it to active here.
		global.gamepadID = _gamepadID;
		show_debug_message("gamepad {0} connected", global.gamepadID);
		return;
	case "gamepad lost":
		// Make sure the disconnected gamepad is the same as the one that was being utilized by the game. If 
		// not, that gamepad will remain connected to the game.
		if (gamepad_is_connected(global.gamepadID))
			return;
		show_debug_message("gamepad {0} disconnected", global.gamepadID);
		
		// Reset the gamepad state and return control inputs back to the keyboard automatically.
		global.gamepadID = -1;
		global.flags &= ~GAME_FLAG_GAMEPAD_ACTIVE;
		return;
}