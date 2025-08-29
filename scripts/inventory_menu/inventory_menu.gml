#region Macros for Inventory Menu Struct

// Macros for flag bits that are unique to the inventory menu.
#macro	MENUINV_FLAG_CAN_CLOSE			0x00000001
#macro	MENUINV_FLAG_OPENED				0x00000002
#macro	MENUINV_FLAG_CAN_CHANGE_PAGE	0x00000004

// Macros for checking the current state of the flag bits for the inventory menu. They are used by the active
// submenu to check if they can or cannot perform certain actions to the inventory.
#macro	MENUINV_CAN_CLOSE				((flags & MENUINV_FLAG_CAN_CLOSE)		!= 0)
#macro	MENUINV_IS_OPENED				((flags & MENUINV_FLAG_OPENED)			!= 0)
#macro	MENUINV_CAN_CHANGE_PAGE			((flags & MENUINV_FLAG_CAN_CHANGE_PAGE) != 0)

// Index values for the positions of the submenu references within the inventory's "menuRef" array. The final
// value is the sum of the number of submenus which is also the length of the array the references reside in.
#macro	MENUINV_INDEX_ITEM_MENU			0
#macro	MENUINV_INDEX_NOTE_MENU			1
#macro	MENUINV_INDEX_MAP_MENU			2
#macro	MENUINV_TOTAL_SUBMENUS			3

// Determines the speed that the inventory menu's current opacity will increase or decrease depending on if 
// the menu is opening or closing, respectively.
#macro	MENUINV_OANIM_ALPHA_SPEED		0.075
#macro	MENUINV_CANIM_ALPHA_SPEED		0.075

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
	///	The inventory menu struct's create event. Required menu parameters are initialized, the required 
	/// options for the inventory which are made up of menus that represent each option as a "section" instead 
	/// of a standard menu option. Finally, control groups are made for each section since they will all have
	/// different input requirements aside from standard menu input functionality.
	///	
	create_event = function(){
		// Get a reference to this menu so it can be passed into the submenus that it manages.
		selfRef	= instance_find_struct(structID);
		flags	= flags | MENUINV_FLAG_CAN_CLOSE; // Initially enable the flag to allow this menu to close.
		object_set_state(state_open_animation);
		
		// Initialize the menu's base parameters as well as its option parameters. Since this menu works as
		// more of a manager of other menus, these options won't have logic for selection and the menu will
		// only show the current option (AKA menu) that is visible for the player to interact with.
		initialize_params(0, 0, true, true, 3, 1, 1);
		initialize_option_params(5, 2, 0, 0);
		
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
			if (menuRef[i] != noone)
				instance_destroy_menu_struct(menuRef[i]);
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
		draw_sprite_ext(spr_rectangle, 0, _xPos, _yPos, display_get_gui_width(), display_get_gui_height(), 
			0.0, COLOR_BLACK, alpha * 0.5);
		
		draw_set_font(fnt_medium);
		draw_text_shadow(_xPos + optionX, _yPos + optionY, options[| curOption].oName, 
			COLOR_WHITE, alpha, COLOR_BLACK, alpha * 0.75);
			
		// Ensure the current submenu's alpha always matches the main menu's alpha level, so they don't each
		// need their own opening/closing animations that would just match the inventory's.
		var _alpha = alpha;
		with(menuRef[curOption])
			alpha = _alpha;
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

		var _isOpened = MENUINV_IS_OPENED;
		if (menuRef[_index] != noone){
			with(menuRef[_index]){ // Simply activate the menu in question if it has already been created.
				if (_isOpened) { object_set_state(state_default); }
				flags = flags | MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE;
			}
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
		if (_menuInstance == noone)
			_menuInstance = ds_map_find_value(global.sInstances, _menu);
		
		// Store the reference to the inventory's page and then set the flags that activate the menu as the
		// current page. A reference to this main management menu is also passed in as the page's previous
		// menu, so it knows it is not the root menu.
		menuRef[_index]	= _menuInstance;
		with(_menuInstance){
			if (_isOpened) { object_set_state(state_default); }
			flags	    = flags | MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE;
			prevMenu	= other.selfRef;
		}
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
			inputFlags = inputFlags | (MENU_PAD_INV_RIGHT			 ); // Offset based on position of the bit within the variable.
			inputFlags = inputFlags | (MENU_PAD_INV_LEFT		<<  1);
			return;
		}
		
		inputFlags = inputFlags | (MENU_KEY_INV_RIGHT			 ); // Offset based on position of the bit within the variable.
		inputFlags = inputFlags | (MENU_KEY_INV_LEFT		<<  1);
	}
	
	/// @description 
	///	The inventory's default state, whichis responsible for managing which page of the inventory is
	/// currently active out of the three: items, notes, and maps. It also handles closing the inventory and
	/// all of those pages (If they have been instantiated throughout the lifetime of the inventory) if 
	/// required.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		// Grab the inputs for the current frame, but using the inventory's unique version of this function.
		process_player_input();
		
		// Only process this chunk of code if the inventory is currently allowed to close on detection of the
		// return key being pressed. Since the inventory only tracks two inputs for shifting between sections,
		// the current section's return key input detection is used.
		if (MENUINV_CAN_CLOSE){
			var _closeMenu = false;
			with(menuRef[curOption]){ // Check for the return key being released.
				if (MINPUT_IS_RETURN_RELEASED){
					object_set_state(0);
					_closeMenu = true;
				}
			}
			
			// Only if _closeMenu is set to true will the inventory begin its closing animation, and that
			// value is only set to true if the current section's return input was released for this frame.
			if (_closeMenu){
				object_set_state(state_close_animation);
				return;
			}
		}
		
		// Don't allow the inventory menu to switch pages (The "pages" in question are the item, note, and map
		// sections, respectively) if its flag to allow so is currently cleared.
		if (!MENUINV_CAN_CHANGE_PAGE)
			return;
		
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
			flags = flags & ~(MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE);
		initialize_submenu(curOption);
	}
	
	/// @description 
	///	The inventory's opening animation which is set as its initial state when opened. Once the conditions
	/// of the animation are met, the inventory will shift to its default state and the currently visible
	/// submenu will do so as well to allow their input and logic functionalities to be processed.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_open_animation = function(_delta){
		alpha += MENUINV_OANIM_ALPHA_SPEED * _delta;
		if (alpha >= 1.0){
			flags = flags | MENUINV_FLAG_OPENED | MENUINV_FLAG_CAN_CHANGE_PAGE;
			alpha = 1.0;
			object_set_state(state_default);
			
			with(menuRef[curOption])
				object_set_state(state_default);
			return;
		}
	}
	
	/// @description 
	///	The inventory's closing animation which is set as its state whenever the inventory is set to close so
	/// gameplay can return to normal once the conditions for the animation are met.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_close_animation = function(_delta){
		alpha -= MENUINV_CANIM_ALPHA_SPEED * _delta;
		if (alpha <= 0.0) { instance_destroy_menu_struct(selfRef); }
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
	if (_ref == noone) // The inventory already exists; don't attempt to create another instance.
		return;
	with(_ref){
		_index = clamp(_index, MENUINV_INDEX_ITEM_MENU, MENUINV_INDEX_MAP_MENU);
		initialize_submenu(_index);
		curOption = _index;
	}
}

#endregion Inventory Menu Global Function Definitions