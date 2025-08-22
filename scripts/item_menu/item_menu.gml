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
	// 
	invItemRefs		= array_create(array_length(global.curItems), INV_EMPTY_SLOT);
	
	// 
	itemOptionsMenu	= noone;
	selfRef			= noone;
	
	/// @description 
	///	
	///	
	create_event = function(){
		// Get a referfence to this struct so its submenu can reference it in its "prevMenu" variable.
		selfRef			= instance_find_struct(structID);
		
		// Set up the "auxilliary" return inputs to the input that opens up this menu during gameplay, so 
		// it can also close the menu should the player choose to use it instead of the standard input.
		var _inputs		= global.settings.inputs;
		keyAuxReturn	= _inputs[STNG_INPUT_ITEM_MENU];
		padAuxReturn	= _inputs[STNG_INPUT_ITEM_MENU + 1];
		
		// 
		var _invSize	= array_length(invItemRefs);
		initialize_params(x, y, true, true, 1, 1, min(_invSize, 12), 0, 0);
		initialize_option_params(display_get_gui_width() - 120, 20, 50, 10, fa_left, fa_top, true);
		
		// Looping through the player's items so they can be added as options to this menu. From here, the
		// player will be able to select a highlighted item to interact with in in various ways relative to
		// the item's type and potential subtype.
		var _itemName	= "";
		var _itemInfo	= "";
		var _itemID		= ID_INVALID;
		var _invItem	= INV_EMPTY_SLOT;
		for (var i = 0; i < _invSize; i++){
			_invItem = item_inventory_slot_get_data(i);
			if (_invItem == INV_EMPTY_SLOT){ // Occupy the slot with an empty option.
				add_option("---", "---");
				continue;
			}
			
			// Jump into the current item struct's scope to grab the relevant data for the item menu's option
			// element and reference array can utilize in their initializations.
			with(_invItem){
				_itemName	= itemName;
				_itemInfo	= itemInfo;
				_itemID		= itemID;
			}
			add_option(_itemName, _itemInfo);
			invItemRefs[i] = global.itemIDs[_itemID];
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
		draw_visible_options(_xPos, _yPos, COLOR_DARK_GRAY, 0.75);
		
		// 
		if (curOption >= 0 && curOption < ds_list_size(options)){
			var _curOption = options[| curOption];
			draw_text_shadow(_xPos + 200, _yPos + 150, _curOption.oInfo);
		}
	}

	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		// 
		process_player_input();
		if (MINPUT_IS_AUX_RETURN_RELEASED){
			with(prevMenu) { object_set_state(state_close_animation); }
			return;
		}
		
		// 
		if (MINPUT_IS_SELECT_RELEASED && invItemRefs[curOption] != INV_EMPTY_SLOT){
			with(prevMenu) { flags = flags & ~MENUINV_FLAG_CAN_CLOSE; }
			selOption = curOption;
			
			// 
			var _options	= -1;
			var _itemType	= invItemRefs[selOption].typeID;
			switch(_itemType){
				default: // Undefined item types default to the combine/drop option combo.
				case ITEM_TYPE_AMMO:
				case ITEM_TYPE_COMBINABLE:
					_options = ["Combine", "Drop"];
					break;
				case ITEM_TYPE_WEAPON:
					_options = ["Equip", "Combine", "Reload", "Drop"];
					break;
				case ITEM_TYPE_EQUIPABLE:
					_options = ["Equip", "Combine", "Drop"];
					break;
				case ITEM_TYPE_CONSUMABLE:
				case ITEM_TYPE_KEY_ITEM:
					_options = ["Use", "Combine", "Drop"];
					break;
			}
			
			// 
			var _menuCreated = false;
			if (itemOptionsMenu == noone){
				itemOptionsMenu = create_sub_menu(selfRef, 100, 100, _options, 1, 1, array_length(_options));
				_menuCreated	= true;
			}
				
			// 
			with(itemOptionsMenu){
				object_set_state(state_default);
				flags = flags | MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE;
				
				// 
				if (!_menuCreated){
					replace_options(_options);
					flags		= flags & ~MENUSUB_FLAG_CLOSING;
					selOption	= -1;
					curOption	= 0;
				}
			}
			object_set_state(state_navigating_item_options);
			
			// FOR TESTING
			itemOptionsMenu.alpha = 1.0;
			return;
		}
		
		// 
		update_cursor_position(_delta);
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	//state_open_item_options_menu = function(_delta){
		
	//}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_navigating_item_options = function(_delta){
		// 
		var _selOption	= -1;
		var _isClosing	= false;
		with(itemOptionsMenu){
			_selOption = selOption;
			_isClosing = MENUSUB_IS_CLOSING;
		}
		
		// 
		if (_selOption != -1){
			object_set_state(state_default);
			selOption = -1;
			
			with(prevMenu) { flags = flags | MENUINV_FLAG_CAN_CLOSE; }
			
			var _oName		= "";
			with(itemOptionsMenu){
				_oName		= options[| selOption].oName;
				flags	    = flags & ~(MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE);
			}
			
			show_debug_message("Selected {0}", _oName);
			return;
		}
		
		// 
		if (_isClosing){
			object_set_state(state_default);
			selOption = -1;
			
			with(prevMenu) { flags = flags | MENUINV_FLAG_CAN_CLOSE; }
		}
	}
}

#endregion Item Menu Struct Definition