#region Sub Menu Macro Definitions

// Macros that equal the value of bits that are utilized within the sub menu for various purposes.
#macro	MENUSUB_FLAG_CLOSING			0x00000001
#macro	MENUSUB_FLAG_CAN_CLOSE			0x00000002

// Macros that condense the code required to checks against the flag bits that are utilized by this struct.
#macro	MENUSUB_IS_CLOSING				((flags & MENUSUB_FLAG_CLOSING)		!= 0)
#macro	MENUSUB_CAN_CLOSE				((flags & MENUSUB_FLAG_CAN_CLOSE)	!= 0)

// Since sub menu instances default to a vertical orientation with a width of one option per row, this value
// is used to determine the spacing needed for said default orientation.
#macro	MENUSUB_OPTION_SPACING_Y		9

#endregion Sub Menu Macro Definitions

#region Sub Menu Struct Definition

/// @param {Function}	index	The value of "str_sub_menu" as determined by GameMaker during runtime.
function str_sub_menu(_index) : str_base_menu(_index) constructor{
	// Determines which font will be used to display the sub menu's option names.
	font = fnt_small;
	
	/// @description
	///	Called during every frame that the menu exists for. It will be responsible for rendering its contents
	/// to the game's GUI layer. Note that its position refers to the top-left of the menu itself, and its
	/// contents will be offset from that point based on each of their unique position values.
	///	
	///	@param {Real}	xPos		The menu's current x position, rounded down.
	/// @param {Real}	yPos		The menu's current y position, rounded down.
	///	@param {Real}	shadowColor	Determines the color used for the option text's drop shadow.
	/// @param {Real}	shadowAlpha	Determines the opacity of the option text's drop shadow.
	draw_gui_event = function(_xPos, _yPos, _shadowColor = COLOR_BLACK, _shadowAlpha = 1.0){
		draw_visible_options(font, _xPos, _yPos, _shadowColor, _shadowAlpha);
	}
	
	/// @description 
	///	Replaces the current options contained within this menu with an entirely new set. The dimensions of
	/// the menu can also be updated as required for the new set of options.
	///	
	///	@param {Array<String>}	options			The list of strings that will replace existing options or create new options as required.
	/// @param {Real}			width			Determines how many options will exist on a given row within the menu (Height is calculated as options are added/removed).
	/// @param {Real}			visibleWidth	Number of option columns visible to the player at any given time.
	/// @param {Real}			visibleHeight	Number of option rows visible to the player at any given time.
	replace_options = function(_options, _width, _visibleWidth, _visibleHeight){
		if (!MENU_ARE_OPTIONS_INITIALIZED || !is_array(_options))
			return; // Don't allow this function to be called if the menu's options weren't initialized or the argument is malformed.
		
		// Reset the menu such that it is highlighting the top-left option since the previous values are being
		// replaced. Otherwise, these values could end up outside the new valid range of options.
		curOption		= 0;
		selOption		= -1;
		visibleAreaX	= 0;
		visibleAreaY	= 0;
		
		// Update the width, and visible region size to match the new argument parameters for this function.
		width			= max(1, _width);
		visibleAreaW	= max(1, _visibleWidth);
		visibleAreaH	= max(1, _visibleHeight);
		
		// Loop through the existing option structs; replacing each one's previous oName value with the value
		// found at the same index inside the _options array. Once the previous number of options is passed,
		// new option structs will be created to store additional values.
		var _prevLength = ds_list_size(options);
		var _length		= array_length(_options);
		for (var i = 0; i < _length; i++){
			if (i >= _prevLength){ // A new option struct should be created for the option.
				add_option(_options[i]);
				continue;
			}
			
			with(options[| i]) { oName = _options[i]; }
		}
		
		// If the new set of options happens to be less than the previous size, the extra options will be
		// removed from the menu until the amount matches the length of the _options array.
		while(_prevLength >= _length)
			remove_option(_prevLength--);
	}
	
	/// @description 
	///	The sub menu's single state, which simply allows the cursor to be moved around the menu based on its
	/// set dimensions. The visible region of the menu is also updated during cursor movement as required.
	///	Pressing the selection or return inputs will exit this state and put this sub menu in a waiting state 
	/// so the menu that manages this state can react accordingly.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		// At the start of the state, the player's input is checked and captured to be used throughout the
		// rest of this state.
		process_player_input();
		
		// The sub menu detects the select input was released, so it should invoke its "option selected" state
		// by copying the value of curOption into selOption. The sub menu's state is zeroed out after this.
		if (MINPUT_IS_SELECT_RELEASED){
			selOption = curOption;
			object_set_state(0);
			return;
		}
		
		// The sub menu detects the return input was released (If the necessary flag is set to allow that), 
		// so it should signal that the sub menu needs to be closed; be it through an animation or having it 
		// instantly disappeared depending on context.
		if (MENUSUB_CAN_CLOSE && MINPUT_IS_RETURN_RELEASED){
			flags = flags | MENUSUB_FLAG_CLOSING;
			object_set_state(0);
		}
		
		// No selection or return logic was processed, so another check is made to seeing if a cursor move
		// needs to occur relative to the four inputs it utilizes, and if auto-scrolling is active or not.
		update_cursor_position(_delta);
	}
}

#endregion Sub Menu Struct Definition

#region Global Funcitons for Sub Menus

/// @description 
///	Creates a special type of menu that can have any number of itself existing at any given time. Can be 
/// utilized by menus to have a confirmation window, or a subset of options that appears when an option is
/// selected within that main menu, and so on.
///	
/// @param {Function}			menuToCreate	A instance of a "str_sub_menu" child (Or "str_sub_menu" itself) that will be created.
///	@param {Struct._structRef}	parentMenu		Reference to the menu that is handling this menu.
/// @param {Real}				x				Position on the x axis of the GUI to place the menu.
/// @param {Real}				y				Position on the y axis of the GUI to place the menu.
/// @param {Array<String>}		options			An array of strings that will be used to create the menu's available options.
/// @param {Real}				width			(Optional) Determines the width of the menu; default value is one.
/// @param {Real}				visibleWidth	(Optional) Number of columns that are visible to the user at any given time; default value is one.
/// @param {Real}				visibleHeight	(Optional) Number of rows that are visible to the user at any given time; default value is three.
/// @param {Asset.GMFont}		font			(Optional) Font resource to use when displaying the menu's visible options.
function create_sub_menu(_menuToCreate, _parentMenu, _x, _y, _options, _width = 1, _visibleWidth = 1, _visibleHeight = 3, _font = fnt_small){
	var _submenuRef = instance_create_menu_struct(_menuToCreate);
	with(_submenuRef){
		initialize_params(_x, _y, false, false, _width, _visibleWidth, _visibleHeight);
		initialize_option_params(0, 0, 0, MENUSUB_OPTION_SPACING_Y); // Default menu orientation is vertical.
		flags		= flags | MENUSUB_FLAG_CAN_CLOSE;
		prevMenu	= _parentMenu;
		font		= _font;
		
		// Don't copy over anything from the _options argument if an array wasn't provided. The reference to
		// the sub menu that was just created is simply returned instead.
		if (!is_array(_options))
			return _submenuRef;
			
		// Copy over the array of options into actual the menu's actual option data.
		var _length = array_length(_options);
		for (var i = 0; i < _length; i++)
			add_option(_options[i]);
	}
	return _submenuRef;
}

#endregion Global Funcitons for Sub Menus