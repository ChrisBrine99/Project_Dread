#region Control UI Manager Macro Definitions

// Some default values for "error" states within the control ui manager. They each represent a situation where
// no icon information exists for an input (Ex. gamepad information is only added when a gamepad is connected
// for the first time, and doesn't exist by default).
#macro	ICONUI_BINDING_NONE				0
#macro	ICONUI_NO_ICON				   -1

// Macros for the keys that allow access to the control icon information for the input they represent within
// the game. Both keyboard and gamepad information is stored together so there is no need to create seperate
// macros for both.
#macro	ICONUI_GAME_RIGHT				"g_right"
#macro	ICONUI_GAME_LEFT				"g_left"
#macro	ICONUI_GAME_UP					"g_up"
#macro	ICONUI_GAME_DOWN				"g_down"
#macro	ICONUI_SPRINT					"run"
#macro	ICONUI_INTERACT					"interact"
#macro	ICONUI_READYWEAPON				"readyWeapon"
#macro	ICONUI_FLASHLIGHT				"flashlight"
#macro	ICONUI_USEWEAPON				"useWeapon"

// Two values that represent the information stored for a keyboard/gamepad binding's icon; the sprite resource
// is uses and the subimage/frame to use out of the entire sprite, respectively.
#macro	ICONUI_ICON_SPRITE				0
#macro	ICONUI_ICON_SUBIMAGE			1

#endregion Control UI Manager Macro Definitions

#region Control UI Manager Struct Definition

/// @param {Function}	index	The value of "str_textbox" as determined by GameMaker during runtime.
function str_control_ui_manager(_index) : str_base(_index) constructor {
	flags			= STR_FLAG_PERSISTENT;
	
	// Stores all the currently loaded input binding icon data. This data is stored into structs that contain
	// both the current keyboard and gamepad icons; the latter not loading until a gamepad is connected.
	controlIcons	= ds_map_create();
	
	/// @description 
	///	
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
	}
	
	/// @description 
	///	The control ui manager struct's destroy event. It will clean up anything that isn't automatically 
	/// cleaned up by GameMaker when this struct is destroyed/out of scope.
	///	
	destroy_event = function(){
		var _key = ds_map_find_first(controlIcons);
		while(!is_undefined(_key)){
			delete controlIcons[? _key];
			_key = ds_map_find_next(controlIcons, _key);
		}
		ds_map_destroy(controlIcons);
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
			keyBinding	= _padBinding;
			keyIcon		= other.get_gamepad_icon(_padBinding);
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
	}
}
	
#endregion Control UI Manager Struct Definition