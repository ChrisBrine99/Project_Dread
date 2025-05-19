if (GAME_IS_PAUSED)
	return; // Prevent anything from updating while the game is considered paused.

var _delta = global.deltaTime;
with(par_dynamic_entity){
	if (curState == 0 || !ENTT_IS_ACTIVE)
		continue;
	script_execute(curState, _delta);
}

// Similarly to dynamic entities, the textbox will execute its step event through a provided state function. If
// no function is set OR the textbox isn't currently active, nothing will be executed.
with(TEXTBOX){
	if (curState == 0 || !TBOX_IS_ACTIVE)
		break;
	script_execute(curState, _delta);
}

// Update the camera after all dynamic entities have been updated to ensure that it has accurate position
// coordinates to use when positioning itself with its followed object (If it has one).
with(CAMERA)	{ step_event(_delta); }