if (GAME_IS_PAUSED)
	return; // Prevent anything from updating while the game is considered paused.

var _delta = global.deltaTime;
with(par_dynamic_entity){
	if (curState == 0 || !ENTT_IS_ACTIVE)
		continue;
	script_execute(curState, _delta);
}

// Update the camera after all dynamic entities have been updated to ensure that it has accurate position
// coordinates to use when positioning itself with its followed object (If it has one).
with(CAMERA)	{ step_event(_delta); }

// 
with(TEXTBOX)	{ step_event(_delta); }