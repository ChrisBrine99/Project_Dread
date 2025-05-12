if (GAME_IS_PAUSED)
	return; // Prevent anything from updating while the game is considered paused.

var _delta = global.deltaTime;
with(par_dynamic_entity){
	if (curState == 0 || !ENTT_IS_ACTIVE)
		continue;
	script_execute(curState, _delta);
}

if (keyboard_check_pressed(vk_space)){
	var _itemID = irandom_range(25, 27);
	var _amount = irandom_range(1, 5);
	show_debug_message("adding {1} of item {0}", _itemID, _amount);
	inventory_add_item(_itemID, _amount);
}

// Update the camera after all dynamic entities have been updated to ensure that it has accurate position
// coordinates to use when positioning itself with its followed object (If it has one).
with(CAMERA) { step_event(_delta); }