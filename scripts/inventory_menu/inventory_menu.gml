#region Macros for Inventory Menu Struct

// A flag bit that has unique functionality in the inventory menu. When set, the inventory is allowed to close
// when the player presses the "return" input.
#macro	MENUINV_FLAG_CAN_CLOSE			0x00000001
#macro	MENUINV_CAN_CLOSE				((flags & MENUINV_FLAG_CAN_CLOSE) != 0)

// Index values for the positions of the submenu references within the inventory's "menuRef" array. The final
// value is the sum of the number of submenus which is also the length of the array the references reside in.
#macro	MENUINV_INDEX_ITEM_MENU			0
#macro	MENUINV_INDEX_NOTE_MENU			1
#macro	MENUINV_INDEX_MAP_MENU			2
#macro	MENUINV_TOTAL_SUBMENUS			3

#endregion Macros for Inventory Menu Struct

#region Inventory Menu Struct Definition

/// @param {Function}	index	The value of "str_inventory_menu" as determined by GameMaker during runtime.
function str_inventory_menu(_index) : str_base_menu(_index) constructor {
	// Stores a reference to the three "submenus" that are managed by this main menu: the item menu, note
	// menu, and the map menu, respectively.
	menuRef = array_create(MENUINV_TOTAL_SUBMENUS, noone);
	
	// Holds a reference to the inventory menu itself which is then passed along to the submenus when they
	// are created by the player shifting through its various pages.
	selfRef	= noone;
	
	/// @description 
	///	Called when the inventory menu is first created through "instance_create_menu_struct". It handles
	/// initializing the various parameters required for the menu to function properly, and also pauses the
	/// player's functionality so they don't move while the menu is open.
	///	
	create_event = function(){
		// Get a reference to this menu so it can be passed into the submenus that it manages.
		selfRef				= instance_find_struct(structID);
		alpha				= 1.0;
		object_set_state(state_default);
		
		// Initialize the base parameters for the menu.
		var _x				= 0;
		var _y				= 0;
		var _isActive		= true;
		var _isVisible		= true;
		var _menuWidth		= 3;	// Three "elements" AKA Items, Notes, and Maps
		var _visibleWidth	= 1;
		var _visibleHeight	= 1;
		initialize_params(_x, _y, _isActive, _isVisible, _menuWidth, _visibleWidth, _visibleHeight);
		flags |= MENUINV_FLAG_CAN_CLOSE; // Initially enable the flag to allow this menu to close.
		
		// Initialize the option parameters for the menu.
		var _optionX		= 5;
		var _optionY		= 1;
		var _optionSpacingX	= 0; // No spacing needed since only one option is visible at a time.
		var _optionSpacingY	= 0;
		initialize_option_params(_optionX, _optionY, _optionSpacingX, _optionSpacingY);
		
		// Add "options" for the menu that are simply the names for each page of the inventory. Those pages
		// themselves are unique menu instances that manage their own data and input independent of this one.
		add_option("Items");
		add_option("Notes");
		add_option("Map");
		
		// Finally, pause the player object's functionality as this menu takes over input while it exists.
		with(PLAYER) { pause_player(); }
	}
	
	/// Carry over the reference to the base struct's destroy event so it can be called through the inventory
	/// menu's destroy event function.
	__destroy_event = destroy_event;
	/// @description 
	///	Called whenever the inventory menu is closed by the player. It handles cleaning up memory that was 
	/// allocated from the str_base_menu struct while also freeing up any memory that was allocated by submenus
	/// that were created.
	///	
	destroy_event = function(){
		__destroy_event(); // Executes general menu destroy event
		
		// Loop through and destroy any of the three submenus (Or all of them) that were created during this
		// lifetime of the inventory menu.
		var _length = array_length(menuRef);
		for (var i = 0; i < _length; i++){
			if (menuRef[i] != noone){
				show_debug_message("Submenu {0} ({1}, ID: {2}) has been destroyed.", i, menuRef[i].structIndex, menuRef[i].structID);
				instance_destroy_menu_struct(menuRef[i]);
			}
		}
		
		show_debug_message("Inventory Menu has been Destroyed.");
	}
	
	/// @description 
	///	Creates a new instance of one of the three submenu structs that are handled by this main inventory
	/// menu struct. Each one is only created when needed, but will stay active until the inventory window is
	/// closed, so this function will not do anything if the same index is passed in twice during only one of
	/// the inventory's lifetimes ("lifetime" refers to time between opening and closing the inventory).
	///	
	///	@param {Real}	index	The value that will determine which menu is created by calling this function.
	initialize_submenu = function(_index){
		if (_index < 0 || _index >= array_length(menuRef))
			return; // Invalid index; don't create a menu.
		
		if (menuRef[_index] != noone){
			with(menuRef[_index]) // Simply activate the menu in question if it has already been created.
				flags |= MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE;
			return;
		}
		
		var _menu = noone;
		switch(_index){ // Determine which of the three menus will be created based on the index value.
			case MENUINV_INDEX_ITEM_MENU:	_menu = str_item_menu;	break;
			case MENUINV_INDEX_NOTE_MENU:	_menu = str_note_menu;	break;
			case MENUINV_INDEX_MAP_MENU:	_menu = str_map_menu;	break;
		}
		
		// Attempt to create an instance for the new page of the menu. If an instance already exists somehow
		// this function will return the value "noone" which will then cause the value to be grabbed from the
		// menu's sInstance reference value.
		var _menuInstance = instance_create_menu_struct(_menu);
		if (_menuInstance == noone) { _menuInstance = ds_map_find_value(global.sInstances, _menu); }
		
		// Store the reference to the inventory's page and then set the flags that activate the menu as the
		// current page. A reference to this main management menu is also passed in as the page's previous
		// menu, so it knows it is not the root menu.
		menuRef[_index]	= _menuInstance;
		with(_menuInstance){
			flags	   |= MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE;
			prevMenu	= other.selfRef;
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
		draw_text_shadow(_xPos + optionX, _yPos + optionY, options[| curOption].oName, 
			COLOR_WHITE, alpha, COLOR_BLACK, alpha * 0.75);
			
		// Ensure the current submenu's alpha always matches the main menu's alpha level.
		var _alpha = alpha;
		with(menuRef[curOption]) { alpha = _alpha; }
	}
	
	/// @description 
	///	Since the inventory menu only needs to care about three inputs ("Tabbing" left and right to open each
	/// respectively section of the inventory: items, notes, and maps), those will be the only three inputs
	/// checked. The right and left inputs are also unique to the inventory, and default to the 'C' and 'V'
	/// keys on the keyboard, or the left and right shoulder buttons of the gamepad, respectively.
	///	
	process_player_input = function(){
		prevInputFlags	= inputFlags;
		inputFlags		= 0;
		
		if (GAME_IS_GAMEPAD_ACTIVE){
			inputFlags |= (MENU_PAD_INV_RIGHT			 ); // Offset based on position of the bit within the variable.
			inputFlags |= (MENU_PAD_INV_LEFT		<<  1);
			inputFlags |= (MENU_PAD_RETURN			<<  6);
			return;
		}
		
		inputFlags |= (MENU_KEY_INV_RIGHT			 ); // Offset based on position of the bit within the variable.
		inputFlags |= (MENU_KEY_INV_LEFT		<<  1);
		inputFlags |= (MENU_KEY_RETURN			<<  6);
	}
	
	/// @description 
	///	The inventory's default state, whichis responsible for managing which page of the inventory is
	/// currently active out of the three: items, notes, and maps. It also handles closing the inventory and
	/// all of those pages (If they have been instantiated throughout the lifetime of the inventory) if 
	/// required.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		// Get the player's input state for the frame, and then check if they have closed the menu. Note that
		// the menu will not close if the menu isn't allowed to close itself currently. Switch to another page
		// of the inventory is still possible despite being unable to close it if required.
		process_player_input();
		if (MINPUT_IS_RETURN_RELEASED && MENUINV_CAN_CLOSE){ // Close the menu if possible.
			instance_destroy_struct(MENU_INVENTORY);
			return;
		}
		
		// Store the current option index before calling the function to possibly update the cursor's position.
		// If the value happens to change, the check below will pass and the currently active submenu will be
		// updated accordingly.
		var _prevOption = curOption;
		update_cursor_position(_delta);
		if (_prevOption == curOption)
			return; // No need to change menus until the value in curOption changed.
			
		// Deactivate the previous inventory page/menu and the initialize the current one (If it hasn't already
		// been initialized during this lifetime of the inventory) before activating it.
		with(menuRef[_prevOption])
			flags &= ~(MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE);
		initialize_submenu(curOption);
	}
}

#endregion Inventory Menu Struct Definition

#region Inventory Menu Global Function Definitions

/// @description 
///	Create the invnetory menu, which will pause the player's movements until it is closed once again. Remaining
/// entities will still function normally.
///	
///	@param {Real}	index	Determines which of the three pages of the inventory to open up first.
function menu_inventory_open(_index){
	var _ref = instance_create_menu_struct(str_inventory_menu);
	if (_ref == noone) // THe inventory already exists; don't attempt to create another instance.
		return;
	with(_ref){
		_index = clamp(_index, MENUINV_INDEX_ITEM_MENU, MENUINV_INDEX_MAP_MENU);
		initialize_submenu(_index);
		curOption = _index;
	}
	show_debug_message("Inventory Menu has been initialized.");
}

#endregion Inventory Menu Global Function Definitions