if (GAME_IS_PAUSED)
	return; // Prevent anything from updating while the game is considered paused.

var _delta = global.deltaTime;
with(par_dynamic_entity){
	if (curState == 0 || !ENTT_IS_ACTIVE)
		continue;
	script_execute(curState, _delta);
}

if (keyboard_check_pressed(vk_1)){
	var _itemID = irandom_range(25, 27);
	var _amount = irandom_range(1, 5);
	show_debug_message("adding {1} of item {0}", _itemID, _amount);
	_amount = inventory_add_item(_itemID, _amount);
	if (_amount > 0) { show_debug_message("{1} of item {0} couldn't be added", _itemID, _amount); }
}

if (keyboard_check_pressed(vk_2)){
	var _itemID = irandom_range(25, 27);
	var _amount = irandom_range(1, 5);
	show_debug_message("removing {1} of item {0}", _itemID, _amount);
	_amount = inventory_remove_item(_itemID, _amount);
	if (_amount > 0) { show_debug_message("{1} of item {0} couldn't be removed", _itemID, _amount); }
}

if (keyboard_check_pressed(vk_3)){
	var _slot = irandom_range(0, array_length(global.inventory) - 1);
	var _amount = irandom_range(1, 5);
	show_debug_message("removing {1} from slot {0}", _slot, _amount);
	_amount = inventory_remove_slot(_slot, _amount);
	if (_amount > 0) { show_debug_message("{1} couldn't be removed from slot {0}", _slot, _amount); }
}

if (keyboard_check_pressed(vk_0)){
	var _itemID = irandom_range(25, 27);
	show_debug_message("there are {1} of item {0} current in inventory", _itemID, inventory_count_item(_itemID));
}

// Update the camera after all dynamic entities have been updated to ensure that it has accurate position
// coordinates to use when positioning itself with its followed object (If it has one).
with(CAMERA) { step_event(_delta); }