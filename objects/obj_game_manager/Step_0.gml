if (GAME_IS_PAUSED)
	return; // Prevent anything from updating while the game is considered paused.

// Loop through all existing dynamic entities and execute their state functions should they have a valid state
// set and they're currently toggled to be active. Otherwise, the entity is skipped in the update process.
var _delta = global.deltaTime;
if (!GAME_IS_ROOM_WARP_OCCURRING){ // All entities should pause during a room transition.
	with(par_dynamic_entity){
		if (curState == 0 || !ENTT_IS_ACTIVE)
			continue;
		script_execute(curState, _delta);
	}
}

// Loop through all menus in order of first created to last; updating them all if they have a valid state
// function to call upon and they are currently considered active via their active flag being set. Menus that
// don't meet that criteria are skipped over and prevented from updating.
var _length = ds_list_size(global.menus);
for (var i = 0; i < _length; i++){
	with(global.menus[| i]){
		if (curState == 0 || !MENU_IS_ACTIVE)
			continue;
		script_execute(curState, _delta);
	}
}

// Similarly to dynamic entities, the textbox will execute its step event through a provided state function. 
// If no function is set OR the textbox isn't currently active, nothing will be executed.
with(TEXTBOX){
	if (curState == 0 || !TBOX_IS_ACTIVE)
		break;
	script_execute(curState, _delta);
}

// Much like entities and the textbox, the screen fade will execute its step event through a state function.
// If no funciton is set OR the screen fade isn't being applied, nothing will happen.
with(SCREEN_FADE){
	if (curState == 0 || !FADE_IS_ACTIVE)
		break;
	script_execute(curState, _delta);
}

// Call the cutscene manager's step event if a cutscene is currently being executed. If one isn't currently
// executing, the step event call is ignored and this event continues onward to the code below.
with(CUTSCENE_MANAGER){
	if (!SCENE_IS_ACTIVE)
		return; // Use return to prevent the camera's step event from being executed.
	step_event(_delta);
}

// Update the camera after all dynamic entities have been updated to ensure that it has accurate position
// coordinates to use when positioning itself with its followed object (If it has one).
with(CAMERA){
	if (followedObject == noone)
		return; // Don't allow the camera to update itself if it isn't following an object.
	step_event(_delta); 
}