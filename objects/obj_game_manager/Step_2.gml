// The delta time value is always calculated regardless of the game's current state flags.
global.deltaTime = delta_time / 1000000.0 * GAME_TARGET_FPS;
if (global.deltaTime > GAME_MAX_DELTA) // Limit to 6.0 to prevent glitchy physics at low frame rates.
	global.deltaTime = GAME_MAX_DELTA;

// Update the application's current uptime regardless of the game's current state flags.
var _delta = global.deltaTime;
uptimeFraction += _delta;
if (uptimeFraction >= GAME_TARGET_FPS){
	global.totalUptime++;
	uptimeFraction -= GAME_TARGET_FPS;
}

if (GAME_IS_PAUSED)
	return; // Prevent anything from updating while the game is considered paused.

// Updates the camera viewport's coordinates before any other end step event is called.
with(CAMERA) { end_step_event(_delta); }

// Update all currently existing dynamic and static entities within the room so long as they are also 
// currently active.
with(par_dynamic_entity){
	if (!ENTT_IS_ACTIVE)
		continue;
	end_step_event(_delta);
}
with(par_static_entity){
	if (!ENTT_IS_ACTIVE)
		continue;
	object_update_state(); // TODO -- Replace with unique end_step_event function call like above.
}

// Loop through all currently active menu struct instances; updating their current state to whatever was set
// in their "nextState" variable so a proper state switch doesn't occur in the middle of updating.
var _length = ds_list_size(global.menus);
for (var i = 0; i < _length; i++){
	with(global.menus[| i])
		object_update_state();
}

// Perform code similar to the loop above does for existing menu objects, but for singleton objects that
// utilize state machines but don't need full end_step events like dynamic and static entities do.
with(TEXTBOX)			{ object_update_state(); }
with(TEXTBOX_LOG)		{ object_update_state(); }
with(SCREEN_FADE)		{ object_update_state(); }
with(CUTSCENE_MANAGER)	{ object_update_state(); }

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
if (GAME_IS_GAMEPAD_ACTIVE){
	if (keyboard_check(vk_anykey))
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
if (gamepad_axis_count(_gamepad) > 1 && (gamepad_axis_value(_gamepad, gp_axisrh) != 0.0 || 
		gamepad_axis_value(_gamepad, gp_axisrv) != 0.0))
	global.flags = global.flags | GAME_FLAG_GAMEPAD_ACTIVE;