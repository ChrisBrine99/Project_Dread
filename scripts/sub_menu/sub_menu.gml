#region Sub Menu Macro Definitions

// 
#macro	MENUSUB_FLAG_CLOSING			0x00000001
#macro	MENUSUB_IS_CLOSING				((flags & MENUSUB_FLAG_CLOSING) != 0)

#endregion Sub Menu Macro Definitions

#region Sub Menu Struct Definition

/// @param {Function}	index	The value of "str_sub_menu" as determined by GameMaker during runtime.
function str_sub_menu(_index) : str_base_menu(_index) constructor{
	/// @description
	///	Called during every frame that the menu exists for. It will be responsible for rendering its contents
	/// to the game's GUI layer. Note that its position refers to the top-left of the menu itself, and its
	/// contents will be offset from that point based on each of their unique position values.
	///	
	///	@param {Real}	xPos	The menu's current x position, rounded down.
	/// @param {Real}	yPos	The menu's current y position, rounded down.
	draw_gui_event = function(_xPos, _yPos){
		draw_visible_options(_xPos, _yPos, COLOR_DARK_GRAY, 0.75);
	}
	
	/// @description 
	///	
	///	
	///	@param {Array<String>}	options	
	replace_options = function(_options){
		if (!MENU_ARE_OPTIONS_INITIALIZED || !is_array(_options))
			return;
		
		// 
		var _prevLength = ds_list_size(options);
		var _length		= array_length(_options);
		for (var i = 0; i < _length; i++){
			if (i >= _prevLength){ // A new option struct should be created for the option.
				add_option(_options[i]);
				continue;
			}
			
			with(options[| i]) { oName = _options[i]; }
		}
		
		// 
		while(_prevLength > _length){
			_prevLength--;
			delete options[| _prevLength];
			ds_list_delete(options, _prevLength);
		}
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		process_player_input();
		
		// 
		if (MINPUT_IS_SELECT_RELEASED){
			selOption = curOption;
			object_set_state(0);
			return;
		}
		
		// 
		if (MINPUT_IS_RETURN_RELEASED){
			flags = flags & ~(MENU_FLAG_ACTIVE | MENU_FLAG_VISIBLE);
			flags = flags |   MENUSUB_FLAG_CLOSING;
			object_set_state(0);
		}
		
		// 
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
///	@param {Struct._structRef}	parentMenu		Reference to the menu that is handling this menu.
/// @param {Real}				x				Position on the x axis of the GUI to place the menu.
/// @param {Real}				y				Position on the y axis of the GUI to place the menu.
/// @param {Array<String>}		options			An array of strings that will be used to create the menu's available options.
/// @param {Real}				width			(Optional) Determines the width of the menu; default value is one.
/// @param {Real}				visibleWidth	(Optional) Number of columns that are visible to the user at any given time; default value is one.
/// @param {Real}				visibleHeight	(Optional) Number of rows that are visible to the user at any given time; default value is three.
function create_sub_menu(_parentMenu, _x, _y, _options, _width = 1, _visibleWidth = 1, _visibleHeight = 3){
	var _submenuRef = instance_create_menu_struct(str_sub_menu);
	with(_submenuRef){
		initialize_params(_x, _y, false, false, _width, _visibleWidth, _visibleHeight);
		initialize_option_params(0, 0, 0, 10); // Default menu orientation is vertical.
		prevMenu = _parentMenu;
		
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