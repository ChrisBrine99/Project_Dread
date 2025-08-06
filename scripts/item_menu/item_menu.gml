#region Macros for Item Menu Struct

// Positional offsets of the currently highlighted item's name and description, respectively.
#macro	MENUITM_NAME_TEXT_X				20
#macro	MENUITM_NAME_TEXT_Y				120
#macro	MENUITM_INFO_TEXT_X				20
#macro	MENUITM_INFO_TEXT_Y				132

#endregion Macros for Item Menu Struct

#region Item Menu Struct Definition

/// @param {Function}	index	The value of "str_item_menu" as determined by GameMaker during runtime.
function str_item_menu(_index) : str_base_menu(_index) constructor {
	
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
		var _invSize	= array_length(global.curItems);
		for (var i = 0; i < _invSize; i++){
			_invItem = item_inventory_slot_get_data(i);
			if (_invItem == INV_EMPTY_SLOT){ // Occupy the slot with an empty option.
				add_option("---", "---");
				show_debug_message("Inventory slot {0} is empty.", i + 1);
				continue;
			}
			add_option(_invItem.itemName, _invItem.itemInfo);
			show_debug_message("Inventory slot {0} contains {1} of the item {2}.", 
				i + 1, global.curItems[i].quantity, _invItem.itemName);
		}
			
		object_set_state(state_default);
		alpha = 1.0;
	}
	
	/// @description 
	///	
	///	
	draw_gui_event = function(){
		//var _xPos = floor(x);
		//var _yPos = floor(y);
		
		
		
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

#endregion Item Menu Struct Definition