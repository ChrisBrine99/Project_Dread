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
		// Set up the "auxilliary" return inputs to the input that opens up this menu during gameplay, so 
		// it can also close the menu should the player choose to use it instead of the standard input.
		var _inputs		= global.settings.inputs;
		keyAuxReturn	= _inputs[STNG_INPUT_ITEM_MENU];
		padAuxReturn	= _inputs[STNG_INPUT_ITEM_MENU + 1];
		
		// Initialize base menu parameters. The inventory is a 4 by 6 grid of options. Despite being able to
		// show 24 elements, only the slots currently available to the player will be created.
		var _isActive		= true;
		var _isVisible		= true;
		var _menuWidth		= 4;
		var _visibleHeight	= 6;
		initialize_params(x, y, _isActive, _isVisible, _menuWidth, _menuWidth, _visibleHeight);
		
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
				continue;
			}
			add_option(_invItem.itemName, _invItem.itemInfo);
		}
	}
	
	/// @description
	///	Called during every frame that the menu exists for. It will be responsible for rendering its contents
	/// to the game's GUI layer. Note that its position refers to the top-left of the menu itself, and its
	/// contents will be offset from that point based on each of their unique position values.
	///	
	///	@param {Real}	xPos	The menu's current x position, rounded down.
	/// @param {Real}	yPos	The menu's current y position, rounded down.
	draw_gui_event = function(_xPos, _yPos){
		draw_visible_options(_xPos, _yPos, COLOR_BLACK, alpha * 0.75);
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		process_player_input();
		if (MINPUT_IS_AUX_RETURN_RELEASED){
			with(prevMenu){
				if (MENUINV_CAN_CLOSE)
					object_set_state(state_close_animation); 
			}
			return;
		}
		
		// 
		update_cursor_position(_delta);
	}
}

#endregion Item Menu Struct Definition