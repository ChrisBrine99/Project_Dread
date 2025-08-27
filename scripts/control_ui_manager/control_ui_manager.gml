#region Control UI Manager Macro Definitions

// Some default values for "error" states within the control ui manager. They each represent a situation where
// no icon information exists for an input (Ex. gamepad information is only added when a gamepad is connected
// for the first time, and doesn't exist by default).
#macro	ICONUI_BINDING_NONE				0
#macro	ICONUI_NO_ICON				   -1

// Macros for the keys that allow access to the control icon information for the input they represent within
// the game. Both keyboard and gamepad information is stored together so there is no need to create seperate
// macros for both.
#macro	ICONUI_GAME_RIGHT				"g_right"		// In-Game Input Icon Keys
#macro	ICONUI_GAME_LEFT				"g_left"
#macro	ICONUI_GAME_UP					"g_up"
#macro	ICONUI_GAME_DOWN				"g_down"
#macro	ICONUI_SPRINT					"run"
#macro	ICONUI_INTERACT					"interact"
#macro	ICONUI_READYWEAPON				"readyWeapon"
#macro	ICONUI_FLASHLIGHT				"flashlight"
#macro	ICONUI_USEWEAPON				"useWeapon"
#macro	ICONUI_ITEM_MENU				"item_menu"		// Menu Open/Close Icon Keys
#macro	ICONUI_NOTE_MENU				"note_menu"
#macro	ICONUI_MAP_MENU					"map_menu"
#macro	ICONUI_PAUSE_MENU				"pause_menu"
#macro	ICONUI_MENU_RIGHT				"m_right"		// General Menu Input Icon Keys
#macro	ICONUI_MENU_LEFT				"m_left"
#macro	ICONUI_MENU_UP					"m_up"
#macro	ICONUI_MENU_DOWN				"m_down"
#macro	ICONUI_SELECT					"select"
#macro	ICONUI_RETURN					"return"
#macro	ICONUI_TBOX_ADVANCE				"tbox_adv"		// Menu-Specific Input Icon Keys
#macro	ICONUI_TBOX_LOG					"tbox_log"
#macro	ICONUI_INV_RIGHT				"inv_right"
#macro	ICONUI_INV_LEFT					"inv_left"

// Two values that represent the information stored for a keyboard/gamepad binding's icon; the sprite resource
// is uses and the subimage/frame to use out of the entire sprite, respectively.
#macro	ICONUI_ICON_SPRITE				0
#macro	ICONUI_ICON_SUBIMAGE			1

// Values that determine the direction to draw the control group's element in. By "direction", it simply means
// how the are offset relative to the anchor point of the group, and then offset further by each element after
// that until the whole group is drawn.
#macro	ICONUI_DRAW_LEFT				10
#macro	ICONUI_DRAW_RIGHT				11
#macro	ICONUI_DRAW_UP					12
#macro	ICONUI_DRAW_DOWN				13

// 
#macro	ICONUI_TYPE_UNSET				0
#macro	ICONUI_TYPE_KEYBOARD			1
#macro	ICONUI_TYPE_GAMEPAD				2

#endregion Control UI Manager Macro Definitions

#region Control UI Manager Struct Definition

/// @param {Function}	index	The value of "str_textbox" as determined by GameMaker during runtime.
function str_control_ui_manager(_index) : str_base(_index) constructor {
	flags			= STR_FLAG_PERSISTENT;
	
	// Stores all the currently loaded input binding icon data. This data is stored into structs that contain
	// both the current keyboard and gamepad icons; the latter not loading until a gamepad is connected.
	controlIcons	= ds_map_create();
	
	// Stores the current icons being drawn to the screen. They are all anchored to a position set alongside
	// the data, and will be offset based on the "direction" of the anchor.
	controlGroup	= ds_map_create();
	
	/// @description 
	///	The control ui manager struct's create event. When called, it will initialize the keyboard control
	/// icon information since it doesn't change throughout the runtime of the game. Gamepad icons are not
	/// initialized since those are determined based on the controller that was connected by the user.
	///	
	create_event = function(){
		if (room != rm_init)
			return; // Prevents a call to this function from executing outside of the game's initialization.
		
		// Gets the keyboard binding icons as they exist at the start of the game (This occurs after the 
		// "gameSettings.ini" file is loaded if it exists).
		var _inputs = global.settings.inputs;
		
		// Getting icon info for all in-game keyboard bindings.
		set_keyboard_control_icon(ICONUI_GAME_RIGHT,	_inputs[STNG_INPUT_GAME_RIGHT]);
		set_keyboard_control_icon(ICONUI_GAME_LEFT,		_inputs[STNG_INPUT_GAME_LEFT]);
		set_keyboard_control_icon(ICONUI_GAME_UP,		_inputs[STNG_INPUT_GAME_UP]);
		set_keyboard_control_icon(ICONUI_GAME_DOWN,		_inputs[STNG_INPUT_GAME_DOWN]);
		set_keyboard_control_icon(ICONUI_SPRINT,		_inputs[STNG_INPUT_SPRINT]);
		set_keyboard_control_icon(ICONUI_INTERACT,		_inputs[STNG_INPUT_INTERACT]);
		set_keyboard_control_icon(ICONUI_READYWEAPON,	_inputs[STNG_INPUT_READYWEAPON]);
		set_keyboard_control_icon(ICONUI_FLASHLIGHT,	_inputs[STNG_INPUT_FLASHLIGHT]);
		set_keyboard_control_icon(ICONUI_USEWEAPON,		_inputs[STNG_INPUT_USEWEAPON]);
		
		// Getting icon info for inputs that are tied to opening/closing a given menu.
		set_keyboard_control_icon(ICONUI_ITEM_MENU,		_inputs[STNG_INPUT_ITEM_MENU]);
		
		// Getting icon info for all generic menu-based keyboard bindings.
		set_keyboard_control_icon(ICONUI_MENU_RIGHT,	_inputs[STNG_INPUT_MENU_RIGHT]);
		set_keyboard_control_icon(ICONUI_MENU_LEFT,		_inputs[STNG_INPUT_MENU_LEFT]);
		set_keyboard_control_icon(ICONUI_MENU_UP,		_inputs[STNG_INPUT_MENU_UP]);
		set_keyboard_control_icon(ICONUI_MENU_DOWN,		_inputs[STNG_INPUT_MENU_DOWN]);
		
		// Getting icon info the textbox-specific keyboard bindings.
		set_keyboard_control_icon(ICONUI_TBOX_ADVANCE,	_inputs[STNG_INPUT_TBOX_ADVANCE]);
		set_keyboard_control_icon(ICONUI_TBOX_LOG,		_inputs[STNG_INPUT_TBOX_LOG]);
	}
	
	/// @description 
	///	The control ui manager struct's destroy event. It will clean up anything that isn't automatically 
	/// cleaned up by GameMaker when this struct is destroyed/out of scope.
	///	
	destroy_event = function(){
		// Loop through and delete all control icons structs that exist at the end of the control ui manager's
		// lifetime. Then, the map amanging them is also destroyed.
		var _key = ds_map_find_first(controlIcons);
		while(!is_undefined(_key)){
			delete controlIcons[? _key];
			_key = ds_map_find_next(controlIcons, _key);
		}
		ds_map_destroy(controlIcons);
		
		// Cleaning up any control groups that still happen to exist when the control ui manager struct is
		// destroyed. It deletes the structs contained within each group and the lists containing structs
		// within as well, and then deletes the root struct and destroys the map managing them all.
		var _groupRef, _length;
		_key = ds_map_find_first(controlGroup);
		while(!is_undefined(_key)){
			_groupRef = controlGroup[? _key];
			with(_groupRef){
				_length = ds_list_size(iconsToDraw);
				for (var i = 0; i < _length; i++)
					delete iconsToDraw[| i];
				ds_list_destroy(iconsToDraw);
			}
			delete _groupRef;
			_key = ds_map_find_next(controlGroup, _key);
		}
		ds_map_destroy(controlGroup);
	}
	
	/// @description 
	///	Sets the icon for a given input's keyboard binding. If the same binding that the data already 
	/// represents is passed in as the parameter, no updating logic will occur to prevent wasting time getting 
	/// the same icon information.
	///	
	///	@param {Any}	key			What will be used to reference the control icon data.
	/// @param {Real}	keyBinding	Keyboard constant that will be used to get its icon sprite/subimage data.
	set_keyboard_control_icon = function(_key, _keyBinding){
		with(create_control_icon_struct(_key)){
			if (keyBinding == _keyBinding) // Don't update if there is no need.
				return;
			keyBinding	= _keyBinding;
			keyIcon		= other.get_keyboard_icon(_keyBinding);
		}
	}
	
	/// @description 
	///	Sets the icon for a given input's gamepad binding. If the same binding that the data already represents
	/// is passed in as the parameter, no updating logic will occur to prevent wasting time getting the same
	/// icon information.
	///	
	///	@param {Any}	key			What will be used to reference the control icon data.
	/// @param {Real}	padBinding	Gamepad constant that will be used to get its icon sprite/subimage data.
	set_gamepad_control_icon = function(_key, _padBinding){
		with(create_control_icon_struct(_key)){
			if (padBinding == _padBinding) // Don't update if there is no need.
				return;
			padBinding	= _padBinding;
			padIcon		= other.get_gamepad_icon(_padBinding);
		}
	}
	
	/// @description 
	///	Creates an instance of the struct that is responsible for storing infomation about a given input's
	/// keyboard and gamepad control icon data for use across the entire game's UI.
	///	
	///	@param {Any}	key			What will be used to reference the control icon data.
	create_control_icon_struct = function(_key){
		var _value = ds_map_find_value(controlIcons, _key);
		if (!is_undefined(_value)) // Struct already exists; return its reference.
			return _value;
		
		// Create the struct with its reference stored locally so it can be easily returned after it has been
		// added to the control icon data structure for later use.
		var _controlIconData = {
			keyBinding	: ICONUI_BINDING_NONE,
			keyIcon		: ICONUI_NO_ICON,
			padBinding	: ICONUI_BINDING_NONE,
			padIcon		: ICONUI_NO_ICON,
		};
		ds_map_add(controlIcons, _key, _controlIconData);
		return _controlIconData;
	}
	
	/// @description
	///	Grabs the control icon for the gamepad or the keyboard depending on which of the two is currently the
	/// active method of input. If no valid data exists, the value -1 will be returned as a default value.
	///	
	///	@param {Any}	key		The value tied to ui icon information for a given input in the game.
	get_control_icon = function(_key){
		var _data = ds_map_find_value(controlIcons, _key);
		if (is_undefined(_data)) // No icon data found for the key; return -1 to signify no icon exists.
			return ICONUI_NO_ICON;
		
		// Determine whether the gamepad's icon data or the keyboard's icon data should be returned by the
		// function call. Note that if there isn't a valid array for icon data contained in the required
		// variable given the input method, the function will return -1 to signify no icon exists.
		if (GAME_IS_GAMEPAD_ACTIVE)
			return _data.padIcon;
		return _data.keyIcon;
	}
	
	/// @description
	///	Gets the desired input binding's ui icon so it can be potentially used to display the controls of the
	/// currently active menu/ui element to the player.
	///	
	///	@param {Real}	keyBinding		The virtual keyboard code for the desired input.
	get_keyboard_icon = function(_keyBinding){
		// No binding provided, don't provide an icon sprite and image index pair.
		if (_keyBinding == ICONUI_BINDING_NONE)
			return ICONUI_NO_ICON;
		
		// All top-row number key icons exist in a group much like their keycodes are within the virtual
		// keyboard. No offset is required since the icons are situated at the beginning of the sprite's images.
		if (_keyBinding >= vk_0 && _keyBinding <= vk_9)
			return [spr_key_icons_small, _keyBinding - vk_0];
		
		// All letter icons are stored next to each other within the sprite, so this if statement/formula will
		// ensure the correct one is grabbed for the keycode in question. It is offset by 9 to account for the
		// top-row number keys that are placed before the letters in the sprite's images.
		if (_keyBinding >= vk_a && _keyBinding <= vk_z)
			return [spr_key_icons_small, 10 + _keyBinding - vk_a];
			
		// All function keys are stored in order within the sprite, so a formula will be used again to get the
		// correct image index relative to the function key that is required. No offset is required since these
		// keys are found at the start of the images within said sprite.
		if (_keyBinding >= vk_f1 && _keyBinding <= vk_f12)
			return [spr_key_icons_medium, _keyBinding - vk_f1];
		
		// Finally, all number pad keys are stored in order within the sprite, so a formula is used to get the
		// correct image index. The value is offset by 11 to account for the function key icons that are in
		// front of the number pad key icons in the sprite's image sequence.
		if (_keyBinding >= vk_numpad0 && _keyBinding <= vk_numpad9)
			return [spr_key_icons_medium, 12 + _keyBinding - vk_numpad0];
			
		// The remaining keys have no real pattern to them, so they are all thrown into a single switch
		// statement that looks incredibly disgusting but probably performs faster than anything else I can
		// come up with at the moment...
		switch(_keyBinding){
			default:				return ICONUI_NO_ICON;
			
			// --- Small-sized Key Icons --- //
			case vk_up:				return [spr_key_icons_small, 36];
			case vk_down:			return [spr_key_icons_small, 37];
			case vk_left:			return [spr_key_icons_small, 38];
			case vk_right:			return [spr_key_icons_small, 39];
			case vk_comma:			return [spr_key_icons_small, 40];
			case vk_semicolon:		return [spr_key_icons_small, 41];
			case vk_period:			return [spr_key_icons_small, 42];
			// A question mark icon exists as image 43 but isn't used...
			case vk_quotation:		return [spr_key_icons_small, 44];
			case vk_openbracket:	return [spr_key_icons_small, 45];
			case vk_closebracket:	return [spr_key_icons_small, 46];
			case vk_divide:
			case vk_forwardslash:	return [spr_key_icons_small, 47];
			case vk_backslash:		return [spr_key_icons_small, 48];
			case vk_add:			return [spr_key_icons_small, 49];
			case vk_subtract:		return [spr_key_icons_small, 50];
			case vk_multiply:		return [spr_key_icons_small, 51];
			case vk_equal:			return [spr_key_icons_small, 52];
			case vk_pause:			return [spr_key_icons_small, 53];
			case vk_underscore:		return [spr_key_icons_small, 54];
			case vk_tilde:			return [spr_key_icons_small, 55];
			
			// --- Medium-sized Key Icons --- //
			case vk_tab:			return [spr_key_icons_medium, 22];
			case vk_delete:			return [spr_key_icons_medium, 23];
			case vk_pageup:			return [spr_key_icons_medium, 24];
			case vk_pagedown:		return [spr_key_icons_medium, 25];
			case vk_alt:			return [spr_key_icons_medium, 26];
			case vk_escape:			return [spr_key_icons_medium, 27];
			
			// --- Large-sized Key Icons --- //
			case vk_space:			return [spr_key_icons_large, 0];
			case vk_lshift:
			case vk_rshift:
			case vk_shift:			return [spr_key_icons_large, 1];
			case vk_backspace:		return [spr_key_icons_large, 2];
			case vk_enter:			return [spr_key_icons_large, 3];
			case vk_capslock:		return [spr_key_icons_large, 4];
			case vk_control:		return [spr_key_icons_large, 5];
			case vk_insert:			return [spr_key_icons_large, 6];
			case vk_home:			return [spr_key_icons_large, 7];
			case vk_end:			return [spr_key_icons_large, 8];
			case vk_numberlock:		return [spr_key_icons_large, 9];
			case vk_scrolllock:		return [spr_key_icons_large, 10];
			case vk_lalt:			return [spr_key_icons_large, 11];
			case vk_ralt:			return [spr_key_icons_large, 12];
			
			// --- Extra Large-sized Key Icons --- //
			case vk_lcontrol:		return [spr_key_icons_xlarge, 0];
			case vk_rcontrol:		return [spr_key_icons_xlarge, 1];
		}
	}
	
	/// @description
	///	Determines the current controller that has been plugged in or utilized (PlayStation, Xbox, Nintendo,
	///	Steam Deck, etc.) and uses the appropriate icons for it. If no unique controller icons are found, a
	/// generic set will be used instead. These icons can then be used whenever the gamepad is active to show
	/// the user what buttons they need to press to perform actions in the game and in its ui/menus.
	///	
	///	@param {Real}	padBinding		The virtual gamepad code for the desired input.
	get_gamepad_icon = function(_padBinding){
		if (_padBinding == ICONUI_BINDING_NONE)
			return ICONUI_NO_ICON;
			
		// 
		var _imageIndex		= _padBinding - gp_face1;
		var _spriteIndex	= spr_pad_xbox_icons;
		// TODO -- Add check for controller type so the proper icons can be used.
		
		return [_spriteIndex, _imageIndex];
	}
	
	/// @description 
	///	Creates a control group if possible. If one already exists for the key provided, the reference to
	/// said group is simply returned. Otherwise, a new struct is created that contains information about
	/// the icons within the group, the direction to display the information relative to the "anchor point",
	/// and a padding to determine distance between elements along the displayed direction.
	///	
	/// @param {Any}	key			Value that will be used to reference this control group as needed.
	///	@param {Real}	x			Origin of the group's anchor point along the GUI's x axis.
	/// @param {Real}	y			Origin of the group's anchor point along the GUI's y axis.
	/// @parma {Real}	padding		Number of pixels between each icon/descriptor in the control group.
	/// @param {Real}	direction	Determines how the icons and their optional descriptor text are laid out when drawn to the screen.
	create_control_group = function(_key, _x, _y, _padding, _direction){
		var _data = ds_map_find_value(controlGroup, _key);
		if (!is_undefined(_data))
			return _data; // A group already exists for the key provided; return its data.
			
		var _controlGroup = {
			xPos			: _x,
			yPos			: _y,
			padding			: _padding,
			drawDirection	: _direction,
			iconsToDraw		: ds_list_create(),
			iconType		: ICONUI_TYPE_UNSET,
			
			/// @description 
			///	Calcualtes the position on the GUI layer for all control icons/descriptors found in the 
			///	control group determined by the function's single parameter. The way these positions are 
			/// calculated differ slightly depending on the direction of drawing the content of the group 
			/// relative to its anchor point.
			///	
			/// @param {Bool}	gamepadActive	Determines the type of icons being drawn by the group.
			calculate_group_positions : function(_gamepadActive) {
				var _startTime = get_timer();
				
				// Check whether or not the value is true. If so, the icon type is switched to gamepad. If not,
				// the icon type is switch to keyboard. This allows updating position values on-the-fly as the
				// input method changes.
				if (_gamepadActive) { iconType = ICONUI_TYPE_GAMEPAD; }
				else				{ iconType = ICONUI_TYPE_KEYBOARD; }
				
				// Create a whole mess of variables that will be used for each control icon in the group. They
				// store important information to position and calculate the positions for each icon/descriptor
				// pair; utilizing the offset from the last pair until the list is fully iterated.
				draw_set_font(fnt_small);
				var _xOffset		= xPos;
				var _yOffset		= yPos;
				var _drawDirection	= drawDirection;
				var _sprIndex		= -1;
				var _sprWidth		= 0;
				var _sprHeight		= 0;
				var _strWidth		= 0;
				var _width			= 0;
				var _length			= ds_list_size(iconsToDraw);
				for (var i = 0; i < _length; i++){
					with(iconsToDraw[| i]){
						// Determine which sprite to use based on the currently active input method. Then, this 
						// sprite is used to fill in the _sprWidth and _sprHeight variables, respectively.
						if (_gamepadActive)	{ _sprIndex = iconRef.padIcon; }
						else				{ _sprIndex = iconRef.keyIcon; }
						_sprWidth	= _sprIndex == ICONUI_NO_ICON ? 0 : sprite_get_width(_sprIndex[ICONUI_ICON_SPRITE]);
						_sprHeight	= _sprIndex == ICONUI_NO_ICON ? 0 : sprite_get_height(_sprIndex[ICONUI_ICON_SPRITE]);
						_strWidth	= string_width(descriptor);	// Also calculate the width of the descriptor text.
				
						// Apply the general offsets to the icon and descriptor position values. The descriptor's y
						// offset will always be two pixels lower on the screen than the icon since that looks best.
						iconX		= _xOffset;
						iconY		= _yOffset;
						descriptorX	= _xOffset;
						descriptorY	= _yOffset + 2;
				
						// Determine if some special offsets need to be applied which only occur when drawing to the
						// left relative to the anchor point. In that case, the icon has to be offset by both itself
						// and the descriptor's width; along with the two-pixel padding between the elements.
						if (_drawDirection == ICONUI_DRAW_LEFT){
							iconX	    -= _strWidth + _sprWidth + 2;
							descriptorX	-= _strWidth;
						} else{ // Apply offset as normal since values are right to left.
							descriptorX += _sprWidth + 2;
						}
				
						// Shift upward by the height of the icon to account for the origin of the sprite/descriptor
						// being aligned to their topmost pixels.
						if (_drawDirection == ICONUI_DRAW_UP){
							iconY		-= _sprHeight;
							descriptorY -= _sprHeight;
						}
				
						// Finally, calculate the width of the element plus the two-pixel gap between the icon and
						// its descriptor text. If no descriptor exists, the two-pixel padding is removed to allow
						// one element's descriptor be used for multiple inputs if required.
						_width	= _sprWidth + _strWidth + 2;
						if (descriptor == "") { _width -= 2; }
					}
			
					// Determine how to update the current x/y offset values by checking the direction that the
					// elements will be drawn relative to the anchor point. Then, move onto the next element.
					switch(drawDirection){
						default: // Display leftward by default.
						case ICONUI_DRAW_LEFT:	// Displays each icon/descriptor from left to right.
							_xOffset -= _width + padding;
							continue;
						case ICONUI_DRAW_RIGHT: // Displays each icon/descriptor from right to left.
							_xOffset += _width + padding;
							continue;
						case ICONUI_DRAW_UP:	// Displays each icon/descriptor from bottom up.
							_yOffset -= _sprHeight + padding;
							continue;
						case ICONUI_DRAW_DOWN:	// Displays each icon/descriptor from top down.
							_yOffset += _sprHeight + padding;
							continue;
					}
				}
				show_debug_message("Took {0} microseconds to update input icon positions.", get_timer() - _startTime);
			}
		};
		
		ds_map_add(controlGroup, _key, _controlGroup);
		return _controlGroup;
	}
	
	/// @description 
	///	Adds an icon to a control group. This is a group of icon data and optional descriptor text that are
	/// all drawn relative to the same point on the GUI layer; offset based on the "direction" of the anchor
	/// and the contents of the group.
	///	
	///	@param {Struct._structRef}	controlGroupRef		Reference to the control group the icon will be added to.
	/// @param {Any}				iconDataKey			Value to find the icon's data from within the "controlIcons" data structure.
	/// @param {String}				descriptor			(Optional) Text to be shown alongside the control icon to help explain what the input does.
	add_control_group_icon = function(_controlGroupRef, _iconDataKey, _descriptor = ""){
		var _controlIcon	= ds_map_find_value(controlIcons, _iconDataKey);
		if (is_undefined(_controlIcon))
			return; // The icon data to add to the group couldn't be found; don't add it.
			
		with(_controlGroupRef){
			var _index = ds_list_find_index(iconsToDraw, _controlIcon);
			if (_index != -1)
				return; // Don't add the same icon data reference to the list.
				
			ds_list_add(iconsToDraw, {
				iconX		: 0,
				iconY		: 0,
				iconRef		: _controlIcon,
				descriptorX	: 0,
				descriptorY	: 0,
				descriptor	: _descriptor,
			});
		}
	}
	
	/// @description 
	///	Draws a control group to the screen at the desired opacity value. No position calculations occur
	/// here; it simply displays all control icon/descriptors at wherever they were calculated to be.
	///	
	///	@param {Struct._structRef}	controlGroupRef		Referece to the control group that will be drawn.
	/// @param {Real}				alpha				Overall opacity of the icon and descriptor text.
	///	@param {Real}				textColor			(Optional) Determines the color of each icon's descriptor text.
	/// @param {Real}				shadowColor			(Optional) Determines the color of the drop shadow behind all descriptor text.
	/// @param {Real}				shadowAlpha			(Optional) Overall opacity of the drop shadow on drawn text.
	draw_control_group = function(_controlGroupRef, _alpha, _textColor = COLOR_WHITE, _shadowColor = COLOR_BLACK, _shadowAlpha = 1.0){
		with(_controlGroupRef){
			// First, check to see if the current icon type matches the currently active input method. If it
			// doesn't (Or it hasn't even been set yet), the positions for each icon/descriptor pair will be
			// updated once before rendering and then will remain that way until the input method changes.
			var _gamepadActive = GAME_IS_GAMEPAD_ACTIVE;
			if ((_gamepadActive && iconType != ICONUI_TYPE_GAMEPAD) || (!_gamepadActive && iconType != ICONUI_TYPE_KEYBOARD))
				calculate_group_positions(_gamepadActive);
			
			// Loop through each icon that will be drawn for the current control group.
			var _iconType	= iconType;
			var _iconData	= ICONUI_NO_ICON;
			var _length		= ds_list_size(iconsToDraw);
			for (var i = 0; i < _length; i++){
				with(iconsToDraw[| i]){
					// Determine if the gamepad or keyboard icon should be utilized, and grab the relevant
					// data for the currently active input method.
					if (_gamepadActive) { _iconData = iconRef.padIcon; }
					else				{ _iconData = iconRef.keyIcon; }
					
					// Get a reference to the two-value array in the icon reference's data that determine
					// the sprite index and its subimage to use for the icon, respectively. If no valid data
					// is provided, the iocn rendering is skipped.
					if (_iconData != ICONUI_NO_ICON){
						draw_sprite_ext(_iconData[ICONUI_ICON_SPRITE], _iconData[ICONUI_ICON_SUBIMAGE], 
							iconX, iconY, 1.0, 1.0, 0.0, COLOR_TRUE_WHITE, _alpha);
					}
						
					// After the icon is drawn (Or is skipped over since no valid data was present), the 
					// descriptor is drawn at its determined position.
					draw_text_shadow(descriptorX, descriptorY, descriptor, _textColor, _alpha, _shadowColor, _shadowAlpha);
				}
			}
		}
	}
}
	
#endregion Control UI Manager Struct Definition