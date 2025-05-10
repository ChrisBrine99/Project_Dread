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
		
		with(global.settings){ // Apply the proper stick deadzone and trigger threshold settings.
			gamepad_set_axis_deadzone(_gamepadID, stickDeadzone);
			gamepad_set_button_threshold(_gamepadID, triggerThreshold);
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