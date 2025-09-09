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

// Various constants relating to the options shown by the inventory menu; their positioning offset relative 
// to the entire menu, and spacing between each option along both axes.
#macro	MENUINV_OPTION_XOFFSET			(display_get_gui_width() >> 1) - 50
#macro	MENUINV_OPTION_YOFFSET			3
#macro	MENUINV_OPTION_XSPACING			50
#macro	MENUINV_OPTION_YSPACING			0

// Index values for the positions of the submenu references within the inventory's "menuRef" array. The final
// value is the sum of the number of submenus which is also the length of the array the references reside in.
#macro	MENUINV_INDEX_ITEM_MENU			0
#macro	MENUINV_INDEX_NOTE_MENU			1
#macro	MENUINV_INDEX_MAP_MENU			2
#macro	MENUINV_TOTAL_SUBMENUS			3

// Determines the characteristics of the opening animation for the inventory; consisting of shifting contents
// from off the top and bottom and the screen onto the screen while its opacity slowly increases to a value
// of 1.0 AKA fully opaque.
#macro	MENUINV_OANIM_ALPHA_SPEED		0.06
#macro	MENUINV_OANIM_MOVE_SPEED		0.25
#macro	MENUINV_OANIM_YTARGET			0.0

// Characteristic for the closing animation for the inventory. It's similar to the opening animation, but
// moves the elements off the top and bottom of the screen linearly instead of the smooth decay of the 
// opening animation's movement logic.
#macro	MENUINV_CANIM_ALPHA_SPEED		0.09
#macro	MENUINV_CANIM_YTARGET		   -20.0

// The macro for the unique key used to store the control icon group for the invenory's cursor movement/page
// shifting input information.
#macro	MENUINV_ICONUI_CTRL_GRP			"menuinv_move_icons"

// Macros for the characteristics of where the inventory's control group will be rendered onto the screen
// relative to the bottom-right of the GUI and the spacing between each icon/descriptor pairs.
#macro	MENUINV_CTRL_GRP_PADDING		2
#macro	MENUINV_CTRL_GRP_XOFFSET		5
#macro	MENUINV_CTRL_GRP_YOFFSET		(VIEWPORT_HEIGHT - 12)

// Each macro represents the index values where each of the two menu cursor movement icon/descriptor pairs 
// and each of the two inventory page shift icon/descriptor pairs, respectively.
#macro	MENUINV_CTRL_GRP_CURSOR_LEFT	0
#macro	MENUINV_CTRL_GRP_CURSOR_RIGHT	1
#macro	MENUINV_CTRL_GRP_CURSOR_UP		2
#macro	MENUINV_CTRL_GRP_CURSOR_DOWN	3
#macro	MENUINV_CTRL_GRP_PAGE_LEFT		4
#macro	MENUINV_CTRL_GRP_PAGE_RIGHT		5

// The macro for the unique key used to store the control icon group for the inventory's selection/return/
// close input information.
#macro	MENUINV_ICONUI_CTRL_GRP2		"menuinv_selret_icons"

// Determines the position of this second control group on the screen, as well as the amount of padding
// between each group's icon/descriptor pair.
#macro	MENUINV_CTRL_GRP2_PADDING		2
#macro	MENUINV_CTRL_GRP2_XOFFSET		(VIEWPORT_WIDTH - 5)
#macro	MENUINV_CTRL_GRP2_YOFFSET		(VIEWPORT_HEIGHT - 12)

// Each macro represents the index values where the menu select icon/descriptor pair and menu return icon/
// descriptor pair, respectively.
#macro	MENUINV_CTRL_GRP2_SELECT		0
#macro	MENUINV_CTRL_GRP2_RETURN		1

// 
#macro	MENUINV_MAINBKG_XRADIUS			210
#macro	MENUINV_MAINBKG_YRADIUS			140
#macro	MENUINV_MAINBKG_ALPHA1			0.8
#macro	MENUINV_MAINBKG_ALPHA2			0.3

//
#macro	MENUINV_HEADER_HEIGHT			14
#macro	MENUINV_FOOTER_Y				(VIEWPORT_HEIGHT - 14)

// 
#macro	MENUINV_SECTION_WIDTH			(VIEWPORT_WIDTH	- 5)
#macro	MENUINV_SECTION_HEIGHT			(MENUINV_FOOTER_Y - MENUINV_HEADER_HEIGHT)

#endregion Macros for Inventory Menu Struct

#region Inventory Menu Struct Definition

/// @param {Function}	index	The value of "str_inventory_menu" as determined by GameMaker during runtime.
function str_inventory_menu(_index) : str_base_menu(_index) constructor {
	// Stores a reference to the three "submenus" that are managed by this main menu: the item menu, note
	// menu, and the map menu, respectively.
	menuRef				= array_create(MENUINV_TOTAL_SUBMENUS, noone);
	
	// Holds a reference to the inventory menu itself which is then passed along to the submenus when they
	// are created by the player shifting through its various pages.
	selfRef				= noone;
	
	// Stores the two control groups utilized by the inventory menu and all of its sections. The references are
	// kept track of here and then are passed to each section as required. Then, rendering of the groups is
	// handled here.
	movementCtrlGroup	= REF_INVALID;
	interactCtrlGroup	= REF_INVALID;
	
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
		initialize_params(0, MENUINV_CANIM_YTARGET, true, true, 3, 3, 1);
		initialize_option_params(MENUINV_OPTION_XOFFSET, MENUINV_OPTION_YOFFSET, 
			MENUINV_OPTION_XSPACING, MENUINV_OPTION_YSPACING, fa_center, fa_top, false);
		
		// Add "options" for the menu that are simply the names for each page of the inventory. Those pages
		// themselves are unique menu instances that manage their own data and input independent of this one.
		add_option("Items");
		add_option("Notes");
		add_option("Map");
		
		// Pause the player object's functionality as this menu takes over input while it exists.
		with(PLAYER) { pause_player(); }
		
		// Attempt to grab the control group that is utilized by the inventory menu. If it doesn't exist, the
		// returned value is undefined and then the group is created and stored in the local value.
		var _movementCtrlGroup = REF_INVALID;
		with(CONTROL_UI_MANAGER){
			_movementCtrlGroup = ds_map_find_value(controlGroup, MENUINV_ICONUI_CTRL_GRP);
			if (!is_undefined(_movementCtrlGroup))
				break; // The control group already exists; exit before attempt to create and add elements again.
			
			// Create the control group at the desired position on the inventory menu, and store the reference
			// it returns so the inventory can then store it for use when drawing the group. Then, add the
			// desired elements to the group in question.
			_movementCtrlGroup = create_control_group(MENUINV_ICONUI_CTRL_GRP, MENUINV_CTRL_GRP_XOFFSET, 
				MENUINV_CTRL_GRP_YOFFSET, MENUINV_CTRL_GRP_PADDING, ICONUI_DRAW_RIGHT);
			add_control_group_icon(_movementCtrlGroup, ICONUI_MENU_LEFT);
			add_control_group_icon(_movementCtrlGroup, ICONUI_MENU_RIGHT);
			add_control_group_icon(_movementCtrlGroup, ICONUI_MENU_UP);
			add_control_group_icon(_movementCtrlGroup, ICONUI_MENU_DOWN, "Cursor");
			add_control_group_icon(_movementCtrlGroup, ICONUI_INV_LEFT);
			add_control_group_icon(_movementCtrlGroup, ICONUI_INV_RIGHT, "Page");
		}
		
		// After the required section has had its menu initialized, its control group information is grabbed
		// if it already exists, or created should the group not currently exists. It will store info for
		// menu interaction inputs.
		var _interactCtrlGroup = REF_INVALID;
		with(CONTROL_UI_MANAGER){
			_interactCtrlGroup = ds_map_find_value(controlGroup, MENUINV_ICONUI_CTRL_GRP2);
			if (!is_undefined(_interactCtrlGroup))
				break;
			
			// Create the control group in question which is used in this menu alongside the note and map
			// menus as they all use the Select/Close inputs.
			_interactCtrlGroup = create_control_group(MENUINV_ICONUI_CTRL_GRP2, MENUINV_CTRL_GRP2_XOFFSET, 
				MENUINV_CTRL_GRP2_YOFFSET, MENUINV_CTRL_GRP2_PADDING, ICONUI_DRAW_LEFT);
			add_control_group_icon(_interactCtrlGroup, ICONUI_SELECT, "Select");
			add_control_group_icon(_interactCtrlGroup, ICONUI_RETURN, "Close");
		}
		
		// Finally, store both references into their respective variables within the inventory menu's data.
		movementCtrlGroup = _movementCtrlGroup;
		interactCtrlGroup = _interactCtrlGroup;
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
	///	@param {Real}	xPos	The menu's current x position added with the viewport's current x position.
	/// @param {Real}	yPos	The menu's current y position added with the viewport's current x position.
	draw_gui_event = function(_xPos, _yPos){
		// A local value that allows menu elements to slide off/on the bottom of the screen as other elements
		// go off/on the otp of the screen alongside the menu y position during the opening/closing animation,
		// respectively. Multiplied by two to cancel out that upward sliding motion of the y value.
		var _yy = (y * 2.0);
		
		#region Render Vignette-style Background Behind Menu Section's Contents
		
			var _alpha = alpha;
			with(global.colorFadeShader){
				activate_shader(COLOR_BLACK);
				draw_circle_ext( // The main portion of the background.
					_xPos + VIEWPORT_HALF_WIDTH, _yPos + VIEWPORT_HALF_HEIGHT,
					MENUINV_MAINBKG_XRADIUS, MENUINV_MAINBKG_YRADIUS,
					COLOR_GRAY, COLOR_WHITE,
					_alpha * MENUINV_MAINBKG_ALPHA1
				);
				set_effect_color(COLOR_VERY_DARK_BLUE);
				draw_circle_ext( // Adds a subtle blue hue to the background.
					_xPos + VIEWPORT_HALF_WIDTH, _yPos + VIEWPORT_HALF_HEIGHT,
					MENUINV_MAINBKG_XRADIUS, MENUINV_MAINBKG_YRADIUS, 
					COLOR_GRAY, COLOR_WHITE,
					_alpha * MENUINV_MAINBKG_ALPHA2
				);
				shader_reset();
			}
		
		#endregion Render Vignette-style Background Behind Menu Section's Contents		
		#region Drawing White Rectangle Around Active Menu Section's Contents
		
			draw_sprite_ext( // Left side of the rectangle.
				spr_rectangle,
				0,		// Unused
				_xPos, _yPos + MENUINV_HEADER_HEIGHT,
				1, MENUINV_SECTION_HEIGHT - _yy,
				0.0,	// Unused
				COLOR_DARK_GRAY, alpha
			);
			draw_sprite_ext( // Right side of the rectangle.
				spr_rectangle,
				0,		// Unused
				_xPos + VIEWPORT_WIDTH - 1, _yPos + MENUINV_HEADER_HEIGHT,
				1, MENUINV_SECTION_HEIGHT - _yy,
				0.0,	// Unused
				COLOR_DARK_GRAY, alpha
			);
			draw_sprite_ext( // Top side of the rectangle.
				spr_rectangle, 
				0,		// Unused 
				_xPos, _yPos + MENUINV_HEADER_HEIGHT - 1,
				VIEWPORT_WIDTH, 1,
				0.0,	// Unused 
				COLOR_DARK_GRAY, alpha
			);
			draw_sprite_ext( // Bottom side of the rectangle.
				spr_rectangle, 
				0,		// Unused 
				_xPos, _yPos + MENUINV_FOOTER_Y - _yy,
				VIEWPORT_WIDTH, 1, 
				0.0,	// Unused
				COLOR_DARK_GRAY, alpha
			);
			
		#endregion Drawing White Rectangle Around Active Menu Section's Contents
		#region Drawing Header and Footer Backgrounds
		
			draw_set_alpha(alpha);
			draw_set_color(COLOR_WHITE);
			gpu_set_tex_filter(true);
			draw_sprite_stretched( // The header background.
				spr_inv_menu_header_footer_bkg, 
				0,	// Unused
				_xPos, _yPos, 
				VIEWPORT_WIDTH, 13
			);
			draw_sprite_stretched( // The footer background.
				spr_inv_menu_header_footer_bkg, 
				0,	// Unused
				_xPos, _yPos - _yy + VIEWPORT_HEIGHT - 13,	
				VIEWPORT_WIDTH, 13
			);
			gpu_set_tex_filter(false);
		
		#endregion Drawing Header and Footer Backgrounds
		
		// After the background elements have all been drawn, the inventory's section names will be drawn 
		// on the top portion of the menu that is outside of the currently active section.
		draw_visible_options(fnt_medium, _xPos, _yPos, COLOR_DARK_GRAY, 1.0);
			
		// Finally, display the icon/descriptor data that exists within the cursor movement and menu 
		// interaction inputs, respectively.
		var _movementCtrlGroup = movementCtrlGroup;
		var _interactCtrlGroup = interactCtrlGroup;
		with(CONTROL_UI_MANAGER){
			draw_control_group(_movementCtrlGroup, _xPos, _yPos, _alpha, COLOR_WHITE, COLOR_DARK_GRAY, _alpha);
			draw_control_group(_interactCtrlGroup, _xPos, _yPos, _alpha, COLOR_WHITE, COLOR_DARK_GRAY, _alpha);
		}
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
		
		// Store the references to each control group so they can be manipulated by the current section if
		// that is needed given the current state of that section. Also store the alpha so it can be copied
		// over since this function can be called both before and after the inventory's opening animation.
		var _movementCtrlGroup	= movementCtrlGroup;
		var _interactCtrlGroup	= interactCtrlGroup;
		var _alpha				= alpha;
		
		// Store the reference to the inventory's page and then set the flags that activate the menu as the
		// current page. A reference to this main management menu is also passed in as the page's previous
		// menu, so it knows it is not the root menu.
		menuRef[_index]	= _menuInstance;
		with(_menuInstance){
			if (_isOpened) { object_set_state(state_default); }
			flags				= flags | MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE;
			prevMenu			= other.selfRef;
			movementCtrlGroup	= _movementCtrlGroup;
			interactCtrlGroup	= _interactCtrlGroup;
			alpha				= _alpha;
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
		// Keep updating the position of the menu until it reaches its target value. The control group managed
		// by this menu and the one managed by the current section will also have their positions updated.
		if (y != MENUINV_OANIM_YTARGET){
			y -= y * MENUINV_OANIM_MOVE_SPEED * _delta;
			
			// Double the inventory's current y position so these upper elements slide up from the bottom 
			// of the screen instead of sliding down alongside the upper elements as they slide down onto the
			// screen from above it.
			var _y	= y * 2.0; 
			with(movementCtrlGroup) { yPos = MENUINV_CTRL_GRP_YOFFSET  - _y; }
			with(interactCtrlGroup)	{ yPos = MENUINV_CTRL_GRP2_YOFFSET - _y; }
				
			// The distance between the current y position and its target is close enough that the animation
			// can finish its movement-based portion. As such, y is set to zero and positional updates will
			// no longer occur.
			if (y > -_delta){
				y = MENUINV_OANIM_YTARGET;
				
				// Also set both control groups to their required target values in case they were some decimal
				// value as y would be despite being higher than the current negative delta.
				with(movementCtrlGroup) { yPos = MENUINV_CTRL_GRP_YOFFSET; }
				with(interactCtrlGroup) { yPos = MENUINV_CTRL_GRP2_YOFFSET; }
			}
		}
		
		// Increase the visibility of the inventory by the desired speed. If the value goes above 1.0 it will
		// be limited back to 1.0 in case it hits that value before the movement portion of the animation has
		// completed.
		if (alpha < 1.0){
			alpha += MENUINV_OANIM_ALPHA_SPEED * _delta;
			if (alpha > 1.0)
				alpha = 1.0;
			
			// Update the current section's alpha level to match the inventory's current alpha.
			var _alpha = alpha;
			with(menuRef[curOption])
				alpha = _alpha;
		}
		
		// The conditions for the animation are checked. If they've been met, the inventory will activate 
		// itself by moving onto its default state, and the current section will have the same occur.
		if (alpha == 1.0 && y == MENUINV_OANIM_YTARGET){
			object_set_state(state_default);
			flags = flags | MENUINV_FLAG_OPENED | MENUINV_FLAG_CAN_CHANGE_PAGE;
			
			with(menuRef[curOption])
				object_set_state(state_default);
		}
	}
	
	/// @description 
	///	The inventory's closing animation which is set as its state whenever the inventory is set to close so
	/// gameplay can return to normal once the conditions for the animation are met.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_close_animation = function(_delta){
		y		= lerp(MENUINV_CANIM_YTARGET, MENUINV_OANIM_YTARGET, alpha);
		var _y	= y * 2.0; // Double current y to allow control groups to slide off the bottom of the screen.
		with(movementCtrlGroup) { yPos = MENUINV_CTRL_GRP2_YOFFSET - _y; }
		with(interactCtrlGroup) { yPos = MENUINV_CTRL_GRP_YOFFSET  - _y; }
		
		alpha  -= MENUINV_CANIM_ALPHA_SPEED * _delta;
		if (alpha <= 0.0){
			instance_destroy_menu_struct(selfRef);
			return;
		}
		
		// Update the current section's alpha level to match the inventory's current alpha.
		var _alpha = alpha;
		with(menuRef[curOption]) 
			alpha = _alpha;
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
		initialize_submenu(_index);
		curOption = _index;
	}
}

#endregion Inventory Menu Global Function Definitions