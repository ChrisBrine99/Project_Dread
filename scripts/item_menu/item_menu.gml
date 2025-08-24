#region Macros for Item Menu Struct

// 
#macro	MENUITM_FLAG_MOVING_ITEM		0x00000001
#macro	MENUITM_IS_MOVING_ITEM			((flags & MENUITM_FLAG_MOVING_ITEM) != 0)

// 
#macro	MENUITM_OPTION_INFO_X			(_xPos + optionX - 10)
#macro	MENUITM_OPTION_INFO_Y			(_yPos + optionY + (visibleAreaH * optionSpacingY) + 20) 

//
#macro	MENUITM_DEFAULT_STRING			"---"

// 
#macro	MENUITM_OPTION_USE				"Use"
#macro	MENUITM_OPTION_EQUIP			"Equip"
#macro	MENUITM_OPTION_UNEQUIP			"Unequip"
#macro	MENUITM_OPTION_COMBINE			"Combine"
#macro	MENUITM_OPTION_MOVE				"Move"
#macro	MENUITM_OPTION_DROP				"Drop"

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
				add_option(MENUITM_DEFAULT_STRING, MENUITM_DEFAULT_STRING);
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
	
	/// 
	__destroy_event = destroy_event;
	/// @description 
	///	
	///
	destroy_event = function(){
		__destroy_event();
		
		if (itemOptionsMenu != noone)
			instance_destroy_menu_struct(itemOptionsMenu);
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
			draw_text_shadow(MENUITM_OPTION_INFO_X, MENUITM_OPTION_INFO_Y, _curOption.oInfo);
		}
	}
	
	/// @description 
	///	Allows a single line of code calling this function to encapsulate all that is required to reset the
	/// item menu back to its default state as it involves more steps than just setting its state back to
	/// state_default.
	///	
	reset_to_default_state = function(){
		with(prevMenu) { flags = flags | MENUINV_FLAG_CAN_CLOSE | MENUINV_FLAG_CAN_CHANGE_PAGE; }
		object_set_state(state_default);
		flags			= flags & ~MENUITM_FLAG_MOVING_ITEM;
		auxSelOption	= -1;
		selOption		= -1;
	}

	/// @description 
	///	The item menu's default state. It will handle selecting a slot within the menu, closing the menu by
	/// releasing the "auxilliary" return input (The master inventory menu manages the standard return input),
	///	and moving the cursor if no option was selected and the menu shouldn't close at the moment.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		// First, process player input for the current frame, and then check if they released the return key.
		// If so, the item menu will signal to the inventory that it is time to play its closing animation.
		process_player_input();
		if (MINPUT_IS_AUX_RETURN_RELEASED){
			// Don't allow the first detection of the release input close the inventory if the value found in
			// auxSelOption isn't default value. If so, reset back to the item menu's default state.
			if (auxSelOption != -1){
				reset_to_default_state();
				return; // Don't let the inventory close itself.
			}
			
			with(prevMenu) { object_set_state(state_close_animation); }
			return; // The menu shouldn't process any other logic.
		}
		
		// Like above for the auxillary return input, the item menu is reset back to its default state but
		// when the normal return input for menus is pressed instead of that auxillary input. That input flag
		// is then cleared so the inventory menu doesn't accidentally detect it and close the menu during the
		// next frame since it is processed before this menu is.
		if (auxSelOption != -1 && MINPUT_IS_RETURN_RELEASED){
			reset_to_default_state();
			prevInputFlags = prevInputFlags & ~MINPUT_FLAG_RETURN;
			return; // The menu shouldn't process any other logic.
		}
		
		// The select input was released, so an item will be selected for the player to interact with its
		// list of available options.
		if (MINPUT_IS_SELECT_RELEASED){
			// Don't jump into any of this selection code logic if the current slot is empty AND the inventory
			// isn't currently set to move an item to another slot. If slot movement is occurring, the check
			// is bypassed to be stopped further below.
			var _isMovingItem = MENUITM_IS_MOVING_ITEM;
			if (!_isMovingItem && invItemRefs[curOption] == INV_EMPTY_SLOT)
				return;
			with(prevMenu) { flags = flags & ~(MENUINV_FLAG_CAN_CLOSE | MENUINV_FLAG_CAN_CHANGE_PAGE); }
			selOption = curOption;
			
			// Check if the inventory is moving an item. If so, this branch is taken and the inventory will
			// move to its state for handling an item movement, and this state exits early.
			if (_isMovingItem){
				object_set_state(state_move_item);
				return;
			}
			
			// If there is a value found in the auxSelOption variable and the moving item flag wasn't set, it
			// is assumed the item is being combined with another instead, so that state is activated.
			if (auxSelOption != -1){
				object_set_state(state_combine_item);
				return;
			}
			
			// Determine the options that the item inventory's sub menu--the item options menu--will have
			// based on its given type ID. This will determine what can and cannot be done to the item.
			var _options	= -1;
			var _itemType	= invItemRefs[selOption].typeID;
			switch(_itemType){
				default: // Undefined item types default to the combine/move/drop option combo.
				case ITEM_TYPE_AMMO:
				case ITEM_TYPE_COMBINABLE:
					_options = [
						MENUITM_OPTION_COMBINE,
						MENUITM_OPTION_MOVE,
						MENUITM_OPTION_DROP
					];
					break;
				case ITEM_TYPE_EQUIPABLE:
				case ITEM_TYPE_WEAPON:
					_options = [
						MENUITM_OPTION_EQUIP, 
						MENUITM_OPTION_COMBINE, 
						MENUITM_OPTION_MOVE, 
						MENUITM_OPTION_DROP
					];
					break;
				case ITEM_TYPE_CONSUMABLE:
				case ITEM_TYPE_KEY_ITEM:
					_options = [
						MENUITM_OPTION_USE,
						MENUITM_OPTION_COMBINE,
						MENUITM_OPTION_MOVE,
						MENUITM_OPTION_DROP
					];
					break;
			}
			
			// Create a local variable that will store whether or not the sub menu struct was created this time
			// through or not. If the menu was created, this bool is set to true and some code below is skipped.
			var _menuCreated = false;
			if (itemOptionsMenu == noone){
				var _menuX			= optionX - 45;
				var _menuY			= optionY + ((curOption - visibleAreaY) * optionSpacingY);
				var _visibleHeight	= array_length(_options);
				itemOptionsMenu		= create_sub_menu(selfRef, _menuX, _menuY, _options, 1, 1, _visibleHeight);
				_menuCreated		= true;
			}
				
			// Jump into scope of the item inventory's sub menu so it can be activated.
			with(itemOptionsMenu){
				object_set_state(state_default);
				flags = flags | MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE;
				
				// If the menu wasn't previously created since it already existed prior to creating this new
				// item option sub menu, the options from the previous time the sub menu was required will be
				// replaced with the new options as determined in the switch/case statement above.
				if (!_menuCreated){
					replace_options(_options, 1, 1, array_length(_options));
					flags = flags & ~MENUSUB_FLAG_CLOSING; // Also flip this bit so the menu doesn't instantly close.
				}
			}
			
			// Finally, switch this menu to wait for the sub menu to have one of its options selected so that
			// option's functionality can be processed within this menu as it contains all the data regarding
			// the items and such.
			object_set_state(state_navigating_item_options);
			
			// FOR TESTING
			itemOptionsMenu.alpha = 1.0;
			return;
		}
		
		// After checking for the relevant non-cursor movements have been checked, the cursor will check if its
		// position should be updated based on its "auto-shift" timer is that is active, or if a direction was
		// pressed in all other instances.
		update_cursor_position(_delta);
	}
	
	/// @description 
	///	The state the item menu is set to whenever its sub menu has been activated. It processes what should
	/// happen depending on what option within the sub menu is selected, or closing that sub menu if needed.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_navigating_item_options = function(_delta){
		// Grab the current value of selOption within the sub menu, and then check if it is currently closing
		// or not. Both values are used below like a menu's select/return inputs are processed to determine
		// what needs to be done within the menu to meet the required criteria for either input.
		var _selOption	= -1;
		var _isClosing	= false;
		with(itemOptionsMenu){
			_selOption = selOption;
			_isClosing = MENUSUB_IS_CLOSING;
		}
		
		// An option in the sub menu was selected, so the selcted option is used to determine what needs to
		// happen within the item menu since it has ties to the player's item inventory and the sub menu is a
		// generic menu that doesn't handle its own selected option(s) automatically.
		if (_selOption != -1){
			var _oName		= "";
			with(itemOptionsMenu){
				_oName		= options[| selOption].oName;
				flags	    = flags & ~(MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE);
			}
			
			// Determine what should be done based on the name of the option that was selected by the player.
			switch(_oName){
				case MENUITM_OPTION_USE:		// Shift to the state that determines how to use the item.
					object_set_state(state_use_item);
					return;
				case MENUITM_OPTION_EQUIP:		// Shift to the state that handles equipping the item.
					object_set_state(state_equip_item);
					return;
				case MENUITM_OPTION_UNEQUIP:	// Shift to the state that handles unequipping the item.
					object_set_state(state_unequip_item);
					return;
				case MENUITM_OPTION_MOVE:		// The item is being moved, so toggle the flag that says that action is occurring in addition to the "Combine" option's line below.
					flags = flags | MENUITM_FLAG_MOVING_ITEM;
				case MENUITM_OPTION_COMBINE:	// The item is being combined; store its slot index, and return to normal inventory function so another can be selected.
					auxSelOption = selOption;
					break;
				case MENUITM_OPTION_DROP:		// Removes slot from the inventory; creates a world item on the floor representing the slot's contents.
					item_inventory_remove_slot(selOption, global.curItems[selOption].quantity);
					invItemRefs[selOption] = INV_EMPTY_SLOT;
					with(options[| selOption]){ // Set the option struct to its default values.
						oName = MENUITM_DEFAULT_STRING;
						oInfo = MENUITM_DEFAULT_STRING;
					}
					reset_to_default_state();
					return;
			}
			
			// In the case of selecting the "Move", "Combine" or "Drop" options, the menu will return to the
			// default state since they either require more information ("Move" and "Combine" require two 
			// selected options in order to function) or have already completed their task ("Drop" only). 
			object_set_state(state_default);
			selOption = -1; // Also reset selOption to -1.
			return;
		}
		
		// The sub menu is closing, so the item inventory should return to its default state. The sub menu is
		// also deactivated since it isn't required during said state.
		if (_isClosing){
			reset_to_default_state();
			with(itemOptionsMenu) { flags = flags & ~(MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE); }
		}
	}
	
	/// @description
	///	
	///
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_use_item = function(_delta){
		show_debug_message("The item in slot {0} was used.", selOption);
		reset_to_default_state();
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_equip_item = function(_delta){
		show_debug_message("The item in slot {0} was equipped.", selOption);
		reset_to_default_state();
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_unequip_item = function(_delta){
		show_debug_message("The item in slot {0} was unequipped.", selOption);
		reset_to_default_state();
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_combine_item = function(_delta){
		show_debug_message("The item in slot {0} was combined the item in slot {1}.", auxSelOption, selOption);
		reset_to_default_state();
	}
	
	/// @description 
	///	Moves the item found in the slot index stored in the auxSelOption variable into the slot occupied by
	/// the item found in the slot index stored in the curOption variable. Resets to the item menu's default
	/// state immediately upon processing this state.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_move_item = function(_delta){
		if (auxSelOption != curOption){ // Only bother swapping data if two unique slots were chosen.
			item_inventory_slot_swap(auxSelOption, curOption);
			
			// Update the references to item structs within the item inventory so the slots they occupy matches
			// where they are now located after the slot swap occurs.
			var _tempInvItemRef			= invItemRefs[auxSelOption];
			invItemRefs[auxSelOption]	= invItemRefs[curOption];
			invItemRefs[curOption]		= _tempInvItemRef;
			
			// Like above, the option contents need to be swapped to match the fact that two items changed
			// places within the item inventory.
			var _tempOptionRef		= options[| auxSelOption];
			options[| auxSelOption] = options[| curOption];
			options[| curOption]	= _tempOptionRef;
		}
		reset_to_default_state();
	}
}

#endregion Item Menu Struct Definition