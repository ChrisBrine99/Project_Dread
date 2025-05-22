#region Macros for Base Menu Struct

// 
#macro	MENU_FLAG_OPTINFO_INITIALIZED	0x01000000
#macro	MENU_FLAG_OPTIONS_INITIALIZED	0x02000000
#macro	MENU_FLAG_PARAMS_INITIALIZED	0x04000000
#macro	MENU_FLAG_SELECTABLE_OPTIONS	0x08000000
#macro	MENU_FLAG_CURSOR_AUTOSCROLL		0x10000000
#macro	MENU_FLAG_VISIBLE				0x20000000
#macro	MENU_FLAG_ACTIVE				0x40000000
// NOTE --- bit 0x80000000 is already used by STR_FLAG_PERSISTENT as defined in the script "base". 

// 
#macro	MENU_IS_OPTINFO_INITIALIZED		((flags & MENU_FLAG_OPTINFO_INITIALIZED)	!= 0)
#macro	MENU_ARE_OPTIONS_INITIALIZED	((flags & MENU_FLAG_OPTIONS_INITIALIZED)	!= 0)
#macro	MENU_ARE_PARAMS_INITIALIZED		((flags & MENU_FLAG_PARAMS_INITIALIZED)		!= 0)
#macro	MENU_HAS_SELECTABLE_OPTIONS		((flags & MENU_FLAG_SELECTABLE_OPTIONS)		!= 0)
#macro	MENU_IS_CURSOR_AUTOSCROLLING	((flags & MENU_FLAG_CURSOR_AUTOSCROLL)		!= 0)
#macro	MENU_IS_VISIBLE					((flags & MENU_FLAG_VISIBLE)				!= 0)
#macro	MENU_IS_ACTIVE					((flags & MENU_FLAG_ACTIVE)					!= 0)

// 
#macro	MINPUT_FLAG_CURSOR_RIGHT		0x00000001
#macro	MINPUT_FLAG_CURSOR_LEFT			0x00000002
#macro	MINPUT_FLAG_CURSOR_UP			0x00000004
#macro	MINPUT_FLAG_CURSOR_DOWN			0x00000008
#macro	MINPUT_FLAG_SELECT				0x00000010
#macro	MINPUT_FLAG_AUX_SELECT			0x00000020
#macro	MINPUT_FLAG_RETURN				0x00000040
#macro	MINPUT_FLAG_AUX_RETURN			0x00000080

// 
#macro	MINPUT_IS_RIGHT_HELD			((inputFlags & MINPUT_FLAG_CURSOR_RIGHT)	!= 0 && (inputFlags & MINPUT_FLAG_CURSOR_LEFT)		== 0)
#macro	MINPUT_IS_LEFT_HELD				((inputFlags & MINPUT_FLAG_CURSOR_LEFT)		!= 0 && (inputFlags & MINPUT_FLAG_CURSOR_RIGHT)		== 0)
#macro	MINPUT_IS_UP_HELD				((inputFlags & MINPUT_FLAG_CURSOR_UP)		!= 0 && (inputFlags & MINPUT_FLAG_CURSOR_DOWN)		== 0)
#macro	MINPUT_IS_DOWN_HELD				((inputFlags & MINPUT_FLAG_CURSOR_DOWN)		!= 0 && (inputFlags & MINPUT_FLAG_CURSOR_UP)		== 0)
#macro	MINPUT_IS_SELECT_PRESSED		((inputFlags & MINPUT_FLAG_SELECT)			!= 0 && (prevInputFlags & MINPUT_FLAG_SELECT)		== 0)
#macro	MINPUT_IS_AUX_SELECT_PRESSED	((inputFlags & MINPUT_FLAG_AUX_SELECT)		!= 0 && (prevInputFlags & MINPUT_FLAG_AUX_SELECT)	== 0)
#macro	MINPUT_IS_RETURN_PRESSED		((inputFlags & MINPUT_FLAG_AUX_RETURN)		!= 0 && (prevInputFlags & MINPUT_FLAG_AUX_RETURN)	== 0)

#endregion Macros for Base Menu Struct

#region Base Menu Struct Definition

/// @param {Function}	index	The value of "str_base_menu" as determined by GameMaker during runtime.
function str_base_menu(_index) : str_base(_index) constructor {
	// Stores the currently executing state, as well as the last state to be executed AND the state to shift to 
	// at the end of the current frame if applicable (Its value matches that of "curState" otherwise).
	curState			= 0;
	nextState			= 0;
	lastState			= 0;
	
	// Stores the inputs that were held versus not held for the current and last frame of gameplay. From this, 
	// checks to see if they've been pressed, held, or released can be performed quickly through bitwise math.
	inputFlags			= 0;
	prevInputFlags		= 0;
	
	// Variables for input that are exclusive to a controller with at least one analog stick (Second pair of
	// values is used for a potential second analog stick). Each pair will simply store the values retrieved
	// from each of the sticks when inputs are handled by the current menu.
	padStickInputLH		= 0.0;
	padStickInputLV		= 0.0;
	padStickInputRH		= 0.0;
	padStickInputRV		= 0.0;
	
	// Variables for input that are exclusive to a menu. They store the value corresponding to the keycodes and
	// gamepad buttons that correspond to secondary inputs that allow a menu option to be selected or the return
	// logic to be activated, respectively.
	keyAuxSelect		= vk_nokey;
	keyAuxReturn		= vk_nokey;
	padAuxSelect		= 0;
	padAuxReturn		= 0;
	
	// Stores the widdth and height of the menu in options.
	width				= 0;	// Set on a per-menu basis.
	height				= 0;	// Set automatically as menu options are added.
	
	// 
	options				= ds_list_create();
	optionX				= 0;
	optionY				= 0;
	optionSpacingX		= 0;
	optionSpacingY		= 0;
	
	// 
	curOption			= -1;
	selOption			= -1;
	auxSelOption		= -1;
	
	// Determines how much of the menu is visible to the user at any given time. This region will be shifted
	// as the cursor is moved relative to what the two variable below this group are set to.
	visibleAreaX		= 0;
	visibleAreaY		= 0;
	visibleAreaW		= 0;
	visibleAreaH		= 0;
	
	// Defines how far from the edge of the visible area along the x or y axis the cursor must be before another
	// movement in the given direction will shift the current viewable region alongside the cursor's movement
	// so long as there are further rows or columns in that movement direction.
	visAreaShiftX		= 0;
	visAreaShiftY		= 0;
	
	// 
	alpha				= 1.0;
	
	destroy_event = function(){
		var _length = ds_list_size(options);
		for (var i = 0; i < _length; i++)
			delete options[| i];
		ds_list_destroy(options);
	}
	
	/// @description
	///	Initializes some default parameters for the menu. Specifically, whether or not it should be active or
	/// visible on start-up, how wide it will be should options be added to the menu, how large the visible
	/// region will be, how that visible region will shift around relative to the cursor's position within the 
	/// menu, and whether or not the options will loop endlessly or have a defined left, right, top, and bottom.
	///	
	/// @param {Real}	isActive		When true, the menu will initialize itself to be active and receptive to user input immediately.
	/// @param {Real}	isVisible		When true, the menu will be rendered onto the screen from the moment it is initialized.
	///	@param {Real}	width			Sets a defined width for the menu (Minimum value of one). The height will be dynamically set as options are added/removed.
	/// @param {Real}	visibleWidth	Determines how many columns of options will be visible at any given time (Minimum value of one).
	/// @param {Real}	visibleHeight	Determines how many rows of options will be visible at any given time (Minimum value of one).
	/// @param {Real}	visAreaShiftX	How close to the horizontal edge of visible options the cursor must be to shift the visible region in that direction if possible.
	/// @param {Real}	visAreaShiftY	How close to the vertical edge of visible options the cursor must be to shift the visible region in that direction if possible.
	///	@param {Bool}	isEndless		(Optional) When true, the menu will loop indefinitely without hitting a first or final row/column.
	initialize_params = function(_isActive, _isVisible, _width, _visibleWidth, _visibleHeight, _visAreaShiftX = 0, _visAreaShiftY = 0, _isEndless = false){
		if (MENU_ARE_PARAMS_INITIALIZED)
			return; // Don't reinitialize menu parameters.
		
		flags |= (_isActive << 30)	// Will be either 0x00000000 or 0x40000000
			   | (_isVisible << 29)	// Will be either 0x00000000 or 0x20000000
			   | MENU_FLAG_PARAMS_INITIALIZED;
		// TODO -- Apply "_isEndless" flag here as well.
		
		// Apply base parameters based on respective argument values.
		width			= max(1, _width);
		visibleAreaW	= max(1, _visibleWidth);
		visibleAreaH	= max(1, _visibleHeight);
		visAreaShiftX	= max(0, _visAreaShiftX);
		visAreaShiftY	= max(0, _visAreaShiftY);
	}
	
	/// @description 
	///	Initializes parameters related to the menu's options. Specifically, it will set the position of the
	/// options themselves on the screen (This position is the top-left corner of the visible region of options),
	/// how far apart those options will be along each axis, and whether or not an option can be indefinitely
	/// selected by the user if that is required for the menu.
	/// 
	///	@param {Real}	x				Position of the top-leftmost currently visible option on the screen along the x axis.
	/// @param {Real}	y				Position of the top-leftmost currently visible option on the screen along the y axis.
	/// @param {Real}	xSpacing		Determines how far each option is apart from each other (Excluding their actual width) along the x axis.
	/// @param {Real}	ySpacing		Determines how far each option is apart from each other (Excluding their actual height) along the y axis.
	/// @param {Bool}	areSelectable	(Optional) When true, options can be selected for more than just the frame the selection input was detected.
	initialize_option_params = function(_x, _y, _xSpacing, _ySpacing, _areSelectable = false){
		if (MENU_ARE_OPTIONS_INITIALIZED)
			return; // Don't reinitialize option parameters.
		
		flags |= (_areSelectable << 25) // Will be either 0x00000000 or 0x02000000
			   | MENU_FLAG_OPTIONS_INITIALIZED;
		
		// Apply base parameters based on respective argument values.
		optionX			= _x;
		optionY			= _y;
		optionSpacingX	= _xSpacing;
		optionSpacingY	= _ySpacing;
	}
	
	/// @description 
	///	Attempts to add an option to the current menu. It takes in a name for the option as the only requirement
	/// which is the string that will be shown to the player when the option is visible on the menu. Optionally,
	///	a description can be provided, and the active state of the option can be set. It can also be inserted
	/// into the current list of options if required, but it appends the option by default.
	///	
	///	@param {String} name			The string that will be shown as the option itself within the menu.
	/// @param {String}	description		(Optional) Supplemental text alongside the option that helps explain what it represents or what selecting it will do.
	///	@param {Bool}	isActive		(Optional) When false, the option cannot be selected by the user.
	/// @param {Real}	index			(Optional) Allows this function to insert the option between others if required.
	add_option = function(_name, _description = "", _isActive = true, _index = -1){
		if (!MENU_ARE_OPTIONS_INITIALIZED)
			return; // Don't create any menu options if the relevant parameters aren't initialized.
		
		var _option = { // Create an initialize a new menu struct.
			oName		: _name,
			oInfo		: _description,
			oIcon		: -1,
			oIconIndex	: 0,
			oIconX		: 0,
			oIconY		: 0,
			isActive	: _isActive,
		};
		
		// Places new option at the end of the menu if the _index parameter is an invalid number. Otherwise, it
		// will insert the option at the specified position. The position of the option is also returned to be
		// referenced as required.
		if (_index < 0 || _index >= ds_list_size(options)){
			ds_list_add(options, _option);
			return;
		}
		ds_list_insert(options, _index, _option);
	}
	
	/// @description 
	///	An extended version of add_option that also provides parameters for adding an image/icon to the menu
	/// option as well as the visible string of text that also represents it. This icon can be positioned 
	/// independently of the option itself when required, or an empty string can be passed in to make the icon
	/// be what represents the option within the menu.
	///	
	///	@param {String}			name			The string that will be shown as the option itself within the menu.
	/// @param {Asset.GMSprite}	sprite			The sprite resource to grab the option's icon from.
	/// @param {Real}			imageIndex		The frame that will be used form the sprite as the option's icon.
	/// @param {Real}			spriteX			X position of the sprite relative to the option's position (Leftmost x value of the "name" string when visible).
	/// @param {Real}			spriteY			Y position of the sprite relative to the option's position (Topmost y value of the "name" string when visible).
	/// @param {String}			description		(Optional) Supplemental text alongside the option that helps explain what it represents or what selecting it will do.
	///	@param {Bool}			isActive		(Optional) When false, the option cannot be selected by the user.
	/// @param {Real}			index			(Optional) Allows this function to insert the option between others if required.
	add_option_ext = function(_name, _sprite, _imageIndex, _spriteX, _spriteY, _description = "", _isActive = true, _index = -1){
		var _size = ds_list_size(options);
		add_option(_name, _description, _isActive, _index);
		if (_size == ds_list_size(options))
			return; // No option was added, return before attempting to process anything and crash.
	
		var _optionIndex = (_index >= 0 && _index < _size) ? _index : _size - 1;
		with(options[| _optionIndex]){
			oIcon		= _sprite;
			oIconIndex	= _imageIndex;
			oIconX		= _spriteX;
			oIconY		= _spriteY;
		}
	}
	
	/// @description 
	///	Attempts to remove the option at the given position within the menu. Will not do anything if an invalid
	/// index is provided or menu options haven't been properly initialized.
	///	
	/// @param {Real}	index	The position of the option that will be removed.
	remove_option = function(_index){
		if (!MENU_ARE_OPTIONS_INITIALIZED || _index < 0 || _index >= ds_list_size(options))
			return; // Don't attempt to remove out of bound indexes or when options aren't initialized.
		ds_list_delete(options, _index);
		
		// Fix edge case where the highlighted option is the last option and that option is also the one being
		// removed. Otherwise curOption will be out of bounds and cause errors.
		var _size = ds_list_size(options);
		if (_size > 1 && _index == _size && curOption == _size)
			curOption--;
	}
	
	/// @description 
	///	Attempts to find the option within a given menu that matches the name string in the function's only
	/// paramter. Returns -1 if menu options haven't been properly initialized.
	///	
	/// @param {String}	name	The visible name of the option to search for.
	find_option_position = function(_name){
		if (!MENU_ARE_OPTIONS_INITIALIZED)
			return -1; // Return default error value is option params haven't been set.
		return ds_list_find_index(options, _name);
	}
	
	/// @description 
	///	Gets player input for the menu in question. It handles getting inputs from both the gamepad and the
	/// keyboard, but prioritizes the one that is currently active. The previous frame's inputs are stored in
	/// the prevInputFlags variable, so the input can be checked to see if it was pressed, held, or released
	/// with only a single keyboard_* or gamepad_* per input.
	///	
	process_player_input = function(){
		prevInputFlags	= inputFlags;
		inputFlags		= 0;
		
		if (GAME_IS_GAMEPAD_ACTIVE){
			inputFlags |= (MENU_PAD_RIGHT				 ); // Offset based on position of the bit within the variable.
			inputFlags |= (MENU_PAD_LEFT			<<  1);
			inputFlags |= (MENU_PAD_UP				<<  2);
			inputFlags |= (MENU_PAD_DOWN			<<  3);
			inputFlags |= (MENU_PAD_SELECT			<<  4);
			inputFlags |= (MENU_PAD_RETURN			<<  6);
			
			// Only check for auxiliary select/return inputs so long as their variables responsible for storing
			// those gamepad bindings are set to something other than their default value, respectively.
			if (padAuxSelect != 0) { inputFlags |= (gamepad_button_check_pressed(global.gamepadID, padAuxSelect) <<  5); }
			if (padAuxReturn != 0) { inputFlags |= (gamepad_button_check_pressed(global.gamepadID, padAuxReturn) <<  7); }
			
			return;
		}
		
		inputFlags |= (MENU_KEY_RIGHT				 ); // Offset based on position of the bit within the variable.
		inputFlags |= (MENU_KEY_LEFT			<<  1);
		inputFlags |= (MENU_KEY_UP				<<  2);
		inputFlags |= (MENU_KEY_DOWN			<<  3);
		inputFlags |= (MENU_KEY_SELECT			<<  4);
		inputFlags |= (MENU_KEY_RETURN			<<  6);
		
		// Only check for auxiliary select/return inputs so long as their variables responsible for storing
		// those keyboard bindings are set to something other than their default value, respectively.
		if (keyAuxSelect != vk_nokey) { inputFlags |= (keyboard_check_pressed(keyAuxSelect) <<  5); }
		if (keyAuxReturn != vk_nokey) { inputFlags |= (keyboard_check_pressed(keyAuxReturn) <<  7); }
	}
}

#endregion Base Menu Struct Definition