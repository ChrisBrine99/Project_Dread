#region Macros for Base Menu Struct

// Macros for the various bits utilized by all menus to determine which aspects of itself are initialized and
// also general flags for if the menu can be rendered or recieve player input, and so on.
#macro	MENU_FLAG_OPTINFO_INITIALIZED	0x01000000
#macro	MENU_FLAG_OPTIONS_INITIALIZED	0x02000000
#macro	MENU_FLAG_PARAMS_INITIALIZED	0x04000000
#macro	MENU_FLAG_SELECTABLE_OPTIONS	0x08000000
#macro	MENU_FLAG_CURSOR_AUTOSCROLL		0x10000000
#macro	MENU_FLAG_VISIBLE				0x20000000
#macro	MENU_FLAG_ACTIVE				0x40000000
// NOTE --- bit 0x80000000 is already used by STR_FLAG_PERSISTENT as defined in the script "base". 

// Macros for checking the various bits within a menu's "flags" variable to see if they're currently cleared
// or set, which can then be used to determine what to happen with regards to the menu in question.
#macro	MENU_IS_OPTINFO_INITIALIZED		((flags & MENU_FLAG_OPTINFO_INITIALIZED)	!= 0)
#macro	MENU_ARE_OPTIONS_INITIALIZED	((flags & MENU_FLAG_OPTIONS_INITIALIZED)	!= 0)
#macro	MENU_ARE_PARAMS_INITIALIZED		((flags & MENU_FLAG_PARAMS_INITIALIZED)		!= 0)
#macro	MENU_HAS_SELECTABLE_OPTIONS		((flags & MENU_FLAG_SELECTABLE_OPTIONS)		!= 0)
#macro	MENU_IS_CURSOR_AUTOSCROLLING	((flags & MENU_FLAG_CURSOR_AUTOSCROLL)		!= 0)
#macro	MENU_IS_VISIBLE					((flags & MENU_FLAG_VISIBLE)				!= 0)
#macro	MENU_IS_ACTIVE					((flags & MENU_FLAG_ACTIVE)					!= 0)

// A unique check to see if a menu hasn't been properly initialized; meaning its option parameters and general
// parameters haven't been setup before the code attempts to perform any menu logic involving such data.
#macro	MENU_NOT_PROPERLY_INITIALIZED	((flags & (MENU_FLAG_OPTIONS_INITIALIZED | MENU_FLAG_PARAMS_INITIALIZED)) != (MENU_FLAG_OPTIONS_INITIALIZED | MENU_FLAG_PARAMS_INITIALIZED))

// Macros for the inputs a menu will check for; stored within a variable named "inputFlags".
#macro	MINPUT_FLAG_CURSOR_RIGHT		0x00000001
#macro	MINPUT_FLAG_CURSOR_LEFT			0x00000002
#macro	MINPUT_FLAG_CURSOR_UP			0x00000004
#macro	MINPUT_FLAG_CURSOR_DOWN			0x00000008
#macro	MINPUT_FLAG_SELECT				0x00000010
#macro	MINPUT_FLAG_AUX_SELECT			0x00000020
#macro	MINPUT_FLAG_RETURN				0x00000040
#macro	MINPUT_FLAG_AUX_RETURN			0x00000080

// Macros to check the state of a given input flag to see if it is currently set or cleared. Note that these
// checks have additional conditions alongside seeing if the bit is set to determine if the input is valid.
#macro	MINPUT_IS_RIGHT_HELD			((inputFlags & MINPUT_FLAG_CURSOR_RIGHT)	!= 0 && (inputFlags & MINPUT_FLAG_CURSOR_LEFT)		== 0)
#macro	MINPUT_IS_LEFT_HELD				((inputFlags & MINPUT_FLAG_CURSOR_LEFT)		!= 0 && (inputFlags & MINPUT_FLAG_CURSOR_RIGHT)		== 0)
#macro	MINPUT_IS_UP_HELD				((inputFlags & MINPUT_FLAG_CURSOR_UP)		!= 0 && (inputFlags & MINPUT_FLAG_CURSOR_DOWN)		== 0)
#macro	MINPUT_IS_DOWN_HELD				((inputFlags & MINPUT_FLAG_CURSOR_DOWN)		!= 0 && (inputFlags & MINPUT_FLAG_CURSOR_UP)		== 0)
#macro	MINPUT_IS_SELECT_PRESSED		((inputFlags & MINPUT_FLAG_SELECT)			!= 0 && (prevInputFlags & MINPUT_FLAG_SELECT)		== 0)
#macro	MINPUT_IS_AUX_SELECT_PRESSED	((inputFlags & MINPUT_FLAG_AUX_SELECT)		!= 0 && (prevInputFlags & MINPUT_FLAG_AUX_SELECT)	== 0)
#macro	MINPUT_IS_RETURN_PRESSED		((inputFlags & MINPUT_FLAG_AUX_RETURN)		!= 0 && (prevInputFlags & MINPUT_FLAG_AUX_RETURN)	== 0)

// A unique check to see if no cursor movement inputs are being held by the player. Prevents having to perform
// four seperate checks on each input since they'll all equal 0 when none are held.
#macro	MINPUT_NO_DIRECTION_HELD		((inputFlags & (MINPUT_FLAG_CURSOR_RIGHT | MINPUT_FLAG_CURSOR_LEFT | MINPUT_FLAG_CURSOR_UP | MINPUT_FLAG_CURSOR_DOWN)) == 0)

// Macros for the values that determine the cursor's movement direction whenever a given direction input is
// currently being held by the user.
#macro	MENU_MOVEMENT_RIGHT				1
#macro	MENU_MOVEMENT_LEFT			   -1
#macro	MENU_MOVEMENT_DOWN				1
#macro	MENU_MOVEMENT_UP			   -1
#macro	MENU_MOVEMENT_NONE				0

// Two values for the menu's autoscrolling functionality whenever a cursor input is continuously held down by
// the player. The first value is the initial interval between the cursor movement occurring, and the second
// value is what is used from that point on until the player stops autoscrolling the cursor.
#macro	MENU_FIRST_AUTOSCROLL_TIME		30.0
#macro	MENU_AUTOSCROLL_TIME			10.0

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
	
	// 
	moveDirectionX		= 0.0;
	moveDirectionY		= 0.0;
	
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
	
	// Variables related to a menu's options. There is a list of "options" that are structs containing info
	// about a given option within the menu, and the remaining values are all parameters that affect the
	// positioning, spacing, and alignment of all currently visible options.
	options				= ds_list_create();
	optionX				= 0;
	optionY				= 0;
	optionSpacingX		= 0;
	optionSpacingY		= 0;
	optionAlignX		= fa_left;
	optionAlignY		= fa_top;
	
	// Stores the index of the option that is currently being highlighted, has been selected, and was selected
	// but has been stored for later use within the menu, respectively.
	curOption			= 0;
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
	
	// Determines the opactity for the entire menu. Unique opacities can reference this one to allow different
	// values that are all kept in step for things like opening/closing animations, and so on.
	alpha				= 0.0;
	
	// Stores the duration the player has been holding a cursor movement key for which is then used to process
	// automatic cursor movement so long as any of those keys are held.
	cursorShiftTimer	= 0.0;
	
	/// @description 
	///	Called whenever a menu is closed. It handles cleaning up memory that was allocated for any menu options,
	/// and can be further extended to clean up additional memory allocated by child menu structs.
	///	
	destroy_event = function(){
		var _length = ds_list_size(options);
		for (var i = 0; i < _length; i++)
			delete options[| i];
		ds_list_destroy(options);
	}
	
	/// @description 
	///	Called during every frame that the menu exists for. It will be responsible for rendering its contents
	/// to the game's GUI layer.
	///	
	draw_gui_event = function() {}
	
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
	initialize_params = function(_isActive, _isVisible, _width, _visibleWidth, _visibleHeight, _visAreaShiftX = 0, _visAreaShiftY = 0){
		if (MENU_ARE_PARAMS_INITIALIZED)
			return; // Don't reinitialize menu parameters.
		
		flags |= (_isActive << 30)	// Will be either 0x00000000 or 0x40000000
			   | (_isVisible << 29)	// Will be either 0x00000000 or 0x20000000
			   | MENU_FLAG_PARAMS_INITIALIZED;
		
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
	///	@param {Real}				x				Position of the top-leftmost currently visible option on the screen along the x axis.
	/// @param {Real}				y				Position of the top-leftmost currently visible option on the screen along the y axis.
	/// @param {Real}				xSpacing		Determines how far each option is apart from each other (Excluding their actual width) along the x axis.
	/// @param {Real}				ySpacing		Determines how far each option is apart from each other (Excluding their actual height) along the y axis.
	/// @param {Constant.HAlign}	xAlign			(Optional) AKA hAlign, this value determines how text is drawn relative to its x position.
	/// @param {Constant.VAlign}	yAlign			(Optional) AKA vAlign, this value determines how text is drawn relative to its y position.
	/// @param {Bool}				areSelectable	(Optional) When true, options can be selected for more than just the frame the selection input was detected.
	initialize_option_params = function(_x, _y, _xSpacing, _ySpacing, _xAlign = fa_left, _yAlign = fa_top, _areSelectable = false){
		if (MENU_ARE_OPTIONS_INITIALIZED)
			return; // Don't reinitialize option parameters.
		
		flags |= (_areSelectable << 25) // Will be either 0x00000000 or 0x02000000
			   | MENU_FLAG_OPTIONS_INITIALIZED;
		
		// Apply base parameters based on respective argument values.
		optionX			= _x;
		optionY			= _y;
		optionSpacingX	= _xSpacing;
		optionSpacingY	= _ySpacing;
		optionAlignX	= _xAlign;
		optionAlignY	= _yAlign;
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
		
		// Update the height of the menu to match the dimensions relative to the set width. If the menu still
		// hasn't reached the desired width, the height will always be set to a value of one.
		var _size = ds_list_size(options);
		height = _size > width ? ceil((_size + 1) / width) : 1;
		
		// Places new option at the end of the menu if the _index parameter is an invalid number. Otherwise, it
		// will insert the option at the specified position. The position of the option is also returned to be
		// referenced as required.
		if (_index < 0 || _index >= _size){
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
		
		// Update the height of the menu to match what the dimensions should be after an element has been
		// removed from it. If the new size is smaller than the desired width, the menu's height is one.
		var _size = ds_list_size(options);
		height = _size > width ? ceil(_size / width) : 1;
		
		// Fix edge case where the highlighted option is the last option and that option is also the one being
		// removed. Otherwise curOption will be out of bounds and cause errors.
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
			// Getting input from the main analog stick by reading its current horizontal and vertical position
			// relative to its centerpoint and the deadzone applied by the game's input settings.
			var _gamepad	= global.gamepadID;
			padStickInputLH = gamepad_axis_value(_gamepad, gp_axislh);
			padStickInputLV = gamepad_axis_value(_gamepad, gp_axislv);
			
			// Getting input from the secondary analog stick if the controller has one.
			if (gamepad_axis_count(global.gamepadID) > 1){
				padStickInputRH	= gamepad_axis_value(_gamepad, gp_axisrh);
				padStickInputRV = gamepad_axis_value(_gamepad, gp_axisrv);
			}
			
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
	
	/// @description 
	///	Processes the cursor movement for the current game frame. It also handles decrementing the timer that
	/// counts durations between automatic cursor shifts if the user is holding down a cursor movement key. If
	/// no movement is detected, the menu itself has a single element, or the menu itself hasn't been properly
	/// initialized, this function will exit early and never update the cursor's position.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	update_cursor_position = function(_delta){
		// Don't bother processing cursor movement on a menu that is smaller than a size of 2 since the cursor
		// will have no place to be or one option to highlight, respectively.
		var _menuSize = ds_list_size(options);
		if (MENU_NOT_PROPERLY_INITIALIZED || _menuSize < 2)
			return;
		
		// Grab the player's input within the current menu for the frame. If no directional inputs are held
		// the function will exit prematurely; resetting the cursor movement timer and the auto scrolling
		// flag if it happens to be set.
		process_player_input();
		
		// This if statement is fucking disgusting but it's the only way to ensure autoscrolling is paused
		// when the gamepad doesn't detect input on the d-pad as well as both potential analog sticks that
		// can also be used for moving the menu's cursor.
		var _noDirectionsHeld = MINPUT_NO_DIRECTION_HELD;
		if (_noDirectionsHeld || (_noDirectionsHeld && GAME_IS_GAMEPAD_ACTIVE && 
				padStickInputLH == 0.0 && padStickInputLV == 0.0 && 
					padStickInputRH == 0.0 && padStickInputRV == 0.0)){
			flags			&= ~MENU_FLAG_CURSOR_AUTOSCROLL;
			cursorShiftTimer = 0.0;
			return;
		}
		
		// Decrement the current remaining time for the cursor's auto-shifting functionality. This timer does
		// not matter if the user is clicking through the options since it will always be reset to 0.0 on no
		// cursor movement/direction inputs being detected.
		cursorShiftTimer -= _delta;
		if (cursorShiftTimer >= 0.0)
			return;

		// Determine the length of duration between cursor movements by checking if the "is autoscrolling"
		// flag is currently set within the menu or not. If so, the interval time is slightly longer than
		// all subsequent cursor position updates.
		if (!MENU_IS_CURSOR_AUTOSCROLLING){
			flags			|= MENU_FLAG_CURSOR_AUTOSCROLL;
			cursorShiftTimer = MENU_FIRST_AUTOSCROLL_TIME;
		} else{
			cursorShiftTimer = MENU_AUTOSCROLL_TIME;
		}
		
		// 
		var _isGamepadActive = GAME_IS_GAMEPAD_ACTIVE;
		if (_isGamepadActive && (padStickInputLH != 0.0 || padStickInputLV != 0.0)){
			moveDirectionX = sign(padStickInputLH); // Converts values from analog to -1, 0, +1.
			moveDirectionY = sign(padStickInputLV);
		} else if (_isGamepadActive && (padStickInputRH != 0.0 || padStickInputRV != 0.0)){
			moveDirectionX = sign(padStickInputRH); // Does the same as above but for the right stick instead.
			moveDirectionY = sign(padStickInputRV);
		} else{ // Uses the gamepad's d-pad or the relevant keyboard keys to return a value of -1, 0, or +1.
			moveDirectionX = ((inputFlags & MINPUT_FLAG_CURSOR_RIGHT)	!= 0) - ((inputFlags & MINPUT_FLAG_CURSOR_LEFT) != 0);
			moveDirectionY = ((inputFlags & MINPUT_FLAG_CURSOR_DOWN)	!= 0) - ((inputFlags & MINPUT_FLAG_CURSOR_UP)	!= 0);
		}
		
		// A small optimization for the smallest possible menu that can have the cursor move. It simply flips
		// the value of curOption between 0 and 1 relative to the correct axis of input being held and the
		// menu's width also matching what is required for the direction of movement (Ex. You can't move the
		// cursor with left/right inputs if the menu's width is 1, and can't use up/down while the width is 2).
		if (_menuSize == 2){
			if ((width == 1 && moveDirectionY != 0) || (width == 2 && moveDirectionX != 0)){
				curOption = !curOption;
				// Make sure the highlighted option is still visible if only one of the two options happens to
				// be visible within this two-option menu if the visible region is set to a size of 1x1.
				if (width == 1 && visibleAreaH == 1)	{ visibleAreaY = curOption; }
				else									{ visibleAreaX = curOption; }
			}
			return;
		}
		
		// Handle vertical movement by seeing if either the upward or downward key was pressed/held by the player,
		// but not both of them. On top of that, this section is skipped if the menu's height is equal to one.
		if (height > 1 && moveDirectionY != 0){
			
			// Determine what to do based on what the current value for "curOption" is and what direction the
			// player has chosen to move their cursor. 
			if (curOption - width < 0 && moveDirectionY == MENU_MOVEMENT_UP){
				curOption	   += width * floor(_menuSize / width);
				if (curOption >= _menuSize)
					curOption  -= width;
				
				// Calculate the topmost visible row by subtracting the visible region's height by the menu's
				// actual height (AKA the total number of rows). The clamp function will ensure this new value
				// never exceeds or goes below what is considered the "valid area" of options for the menu.
				visibleAreaY	= clamp(height - visibleAreaH, 0, floor(curOption / width) - visAreaShiftY + 1);
			} else if (curOption + width >= _menuSize && moveDirectionY == MENU_MOVEMENT_DOWN){
				curOption	   %= width;
				visibleAreaY	= 0;
			} else{
				curOption	   += width * moveDirectionY;
				
				// Determine if the menu's vertical visible region should be shifted upward or downward depending.
				// of the updated "curOption" value as well as the current row the menu cursor is now on.
				var _curRow		= floor(curOption / width);
				if (visibleAreaY + visibleAreaH < height 
						&& _curRow >= visibleAreaY + visibleAreaH - visAreaShiftY){
					visibleAreaY++; // Shift visible area downward.
				} else if (visibleAreaY > 0 && _curRow < visibleAreaY + visAreaShiftY){
					visibleAreaY--; // Shift visible area upward.
				}
			}
		}
		
		// Handle horizontal movement by seeing if either the upward or downward key was pressed/held by the 
		// player, but not both of them. On top of that, this section is skipped if the menu's width is equal
		// to one.
		if (width > 1 && moveDirectionX != MENU_MOVEMENT_NONE){
			var _curColumn		= curOption % width;
			
			// Determine what to do based on the current column the highlighted option is on (This is where the
			// cursor is currently positioned) and what direction the player has chosen to move the cursor.
			if (_curColumn == 0 && moveDirectionX == MENU_MOVEMENT_LEFT){
				curOption		= min(_menuSize - 1, curOption + width - 1);
				visibleAreaX	= clamp(visibleAreaX + width - visibleAreaW, 0, curOption % width - visAreaShiftX + 1);
			} else if (_curColumn == width - 1 && moveDirectionX == MENU_MOVEMENT_RIGHT){
				curOption	   -= width - 1;
				visibleAreaX	= 0;
			} else{
				curOption	   += moveDirectionX;
				
				// Handling wrapping to the leftmost option on the bottom row should it not contain enough
				// options to completely populate the row relative to the menu's width.
				if (moveDirectionX == MENU_MOVEMENT_RIGHT && curOption >= _menuSize){
					curOption	   -= curOption % width;
					visibleAreaX	= 0;
				}
				
				// Determining how to shift the visible region of the menu along the x-axis. It will shift
				// right until hitting the first column, or shift left until hitting the final column.
				_curColumn = curOption % width;
				if (visibleAreaX + visibleAreaW < width 
						&& _curColumn >= visibleAreaX + visibleAreaW - visAreaShiftX){
					visibleAreaX++; // Shift visible area to the right.
				} else if (visibleAreaX > 0 && _curColumn < visibleAreaX + visAreaShiftX){
					visibleAreaX--; // Shift visible area to the left.
				}
			}
		}
	}
	
	/// @description 
	/// Renders the currently visible region of menu options to the screen given the positioning, spacing, and
	/// alignment for each option that is (AND SHOULD ALWAYS BE) set upon initialization of a given menu. This
	/// version will only render the text elements of each option and ignore any potential icons that could
	/// also exist. To draw both text and icons, draw_visible_options_ext must be used.
	/// 
	draw_visible_options = function(){
		draw_set_font(fnt_small);
		draw_set_halign(optionAlignX);
		draw_set_valign(optionAlignY);
		
		// Loop through the visible region of option structs. Each has their color determined on-the-fly
		// relative to their state and how the cursor and menu itself are currently interacting with them.
		var _menuSize	= ds_list_size(options);
		var _curOption	= curOption;
		var _selOption	= selOption;
		var _oIndex		= 0;
		var _xx			= optionX;
		var _yy			= optionY;
		for (var curY = visibleAreaY; curY < visibleAreaY + visibleAreaH; curY++){
			for (var curX = visibleAreaX; curX < visibleAreaX + visibleAreaW; curX++){
				_oIndex = (curY * width) + curX; // Convert to a one-dimensional index.
				
				// The menu has reached its end so the inner loop will be broken out of and the value of curY
				// is set to the earliest value that will break it out of the outer loop to end all drawing.
				if (_oIndex >= _menuSize){
					curY = visibleAreaY + visibleAreaH;
					break; // Exits the inner loop instantly.
				}
				
				// Jump into the scope of the option at the calculated index within the menu. Then, the state
				// of the option is checked to see if it is inactive, selected, highlighted, or simply visible.
				// Each of these will cause it to show up as a different color compared to the rest.
				with(options[| _oIndex]){
					if (!isActive)					{ draw_set_color(COLOR_DARK_GRAY); }
					else if (_selOption == _oIndex) { draw_set_color(COLOR_LIGHT_GREEN); }
					else if (_curOption == _oIndex)	{ draw_set_color(COLOR_LIGHT_YELLOW); }
					else							{ draw_set_color(COLOR_WHITE); }
					
					draw_text(_xx, _yy, oName);
				}
				
				// Shift the x position based on the x spacing set for the menuu when its option parameters 
				// were first initialized.
				_xx += optionSpacingX;
			}
			
			// Shift the y position based on the y spacing set for the menu with its option parameters were
			// first initialized, and then reset the x position back to the leftmost value for the inner loop
			// to have the correct coordinates for the next loop.
			_yy    += optionSpacingY;
			_xx		= optionX;
		}
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
	
	/// @description 
	///	
	///	
	draw_visible_options_ext = function(){
		draw_set_font(fnt_small);
		draw_set_halign(optionAlignX);
		draw_set_valign(optionAlignY);
		
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
}

#endregion Base Menu Struct Definition