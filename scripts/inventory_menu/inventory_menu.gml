#region Macros for Inventory Menu Struct
#endregion Macros for Inventory Menu Struct

#region Inventory Menu Struct Definition

/// @param {Function}	index	The value of "str_inventory_menu" as determined by GameMaker during runtime.
function str_inventory_menu(_index) : str_base_menu(_index) constructor {
	
	/// @description 
	///	
	///	
	create_event = function(){
		// Initialize base menu parameters. The inventory is a 4 by 6 grid of options. Despite being able to
		// show 24 elements, only the slots currently available to the player will be created.
		var _isActive		= true;
		var _isVisible		= true;
		var _menuWidth		= 4;
		var _visibleHeight	= 6;
		initialize_params(_isActive, _isVisible, _menuWidth, _menuWidth, _visibleHeight);
		
		// 
		var _optionX		= 100;
		var _optionY		= 5;
		var _optionSpacingX = 50;
		var _optionSpacingY	= 10;
		initialize_option_params(_optionX, _optionY, _optionSpacingX, _optionSpacingY);
		
		// 
		var _invItem	= INV_EMPTY_SLOT;
		var _invSize	= array_length(global.inventory);
		for (var i = 0; i < _invSize; i++){
			_invItem = inventory_slot_get_item_data(i);
			if (_invItem == INV_EMPTY_SLOT){ // Occupy the slot with an empty option.
				add_option("---", "---");
				show_debug_message("Inventory slot {0} is empty.", i + 1);
				continue;
			}
			add_option(_invItem.itemName, _invItem.itemInfo);
			show_debug_message("Inventory slot {0} contains {1} of the item {2}.", 
				i + 1, global.inventory[i].quantity, _invItem.itemName);
		}
			
		object_set_state(state_default);
		alpha = 1.0;
	}
	
	/// @description 
	///	
	///	
	draw_gui_event = function(){
		draw_text(5, 50, string("cursorShiftTimer: {0}", cursorShiftTimer));
		draw_visible_options();
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		update_cursor_position(_delta);
	}
}

#endregion Inventory Menu Struct Definition