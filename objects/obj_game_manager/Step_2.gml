// The delta time value is always calculated regardless of the game's current state flags.
global.deltaTime = delta_time / 1000000.0 * GAME_TARGET_FPS;

// Update the application's current uptime regardless of the game's current state flags.
uptimeFraction += global.deltaTime;
if (uptimeFraction >= GAME_TARGET_FPS){
	global.totalUptime++;
	uptimeFraction -= GAME_TARGET_FPS;
}

if (GAME_IS_PAUSED)
	return; // Prevent anything from updating while the game is considered paused.

with(CAMERA) { end_step_event(); }	// Updates the camera viewport's coordinates.

// Update all currently existing dynamic entities within the room so long as they are also currently active.
var _delta = global.deltaTime;
with(par_dynamic_entity){
	if (!ENTT_IS_ACTIVE)
		continue;
	end_step_event(_delta);
}

// Loop through all currently active menu struct instances; updating their current state to whatever was set
// in their "nextState" variable so a proper state switch doesn't occur in the middle of updating.
var _length = ds_list_size(global.menus);
for (var i = 0; i < _length; i++){
	with(global.menus[| i]){
		if (curState != nextState){
			lastState = curState;
			curState = nextState;
		}
	}
}

// Update the current state function for the textbox to match the value stored in the "nextState" variable at
// the end of the step event, so state changes don't occur in the middle of a frame.
with(TEXTBOX){
	if (curState != nextState){
		lastState = curState;
		curState = nextState;
	}
}

// Perform the same thing that occurs to the textbox and its state values within the Screen Fade struct.
with(SCREEN_FADE){
	if (curState != nextState){
		lastState = curState;
		curState = nextState;
	}
}

// Update the in-game playtime whenever its flag is toggled.
if (GAME_IS_PLAYTIME_ACTIVE){
	playtimeFraction += global.deltaTime;
	if (playtimeFraction >= GAME_TARGET_FPS){
		global.totalPlaytime++;
		playtimeFraction -= GAME_TARGET_FPS;
	}
}

// Don't bother with any input swapping logic if there isn't a gamepad to get input from.
if (global.gamepadID == -1)
	return;

// Returning control back to the keyboard if a gamepad was previously the active input method but a key on the
// keyboard was pressed by the user during the current frame.
if (GAME_IS_GAMEPAD_ACTIVE && keyboard_check(vk_anykey)){
	global.flags = global.flags & ~GAME_FLAG_GAMEPAD_ACTIVE;
	return;
}

// Looping through all buttons for the gamepad to see if any of them have been pressed by the user. If so,
// control is moved over to the controller that the input was read from.
var _gamepad = global.gamepadID;
for (var i = gp_face1; i <= gp_padr; i++){
	if (gamepad_button_check_pressed(_gamepad, i)){
		global.flags = global.flags | GAME_FLAG_GAMEPAD_ACTIVE;
		return;
	}
}

// Check the primary stick to see if any input is detected from it. If so, move input detection over to the
// connected gamepad.
if (gamepad_axis_value(_gamepad, gp_axislh) != 0.0 || gamepad_axis_value(_gamepad, gp_axislv) != 0.0){
	global.flags = global.flags | GAME_FLAG_GAMEPAD_ACTIVE;
	return;
}

// Finally, the secondary stick is checked (If one exists) for input. If input is found, control is moved over 
// to the connected gamepad.
if (gamepad_axis_count(_gamepad) > 1 && (gamepad_axis_value(_gamepad, gp_axislh) != 0.0 || gamepad_axis_value(_gamepad, gp_axislv) != 0.0))
	global.flags = global.flags | GAME_FLAG_GAMEPAD_ACTIVE;