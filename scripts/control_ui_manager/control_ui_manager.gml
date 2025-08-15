#region Control UI Manager Macro Definitions

// 
#macro	ICONUI_BINDING_NONE				0
#macro	ICONUI_NO_ICON				   -1

// 
#macro	ICONUI_GAME_RIGHT				"g_right"
#macro	ICONUI_GAME_LEFT				"g_left"
#macro	ICONUI_GAME_UP					"g_up"
#macro	ICONUI_GAME_DOWN				"g_down"
#macro	ICONUI_RUN						"g_run"
#macro	ICONUI_INTERACT					"g_interact"

// 
#macro	ICONUI_ICON_SPRITE				0
#macro	ICONUI_ICON_SUBIMAGE			1

#endregion Control UI Manager Macro Definitions

#region Control UI Manager Struct Definition

/// @param {Function}	index	The value of "str_textbox" as determined by GameMaker during runtime.
function str_control_ui_manager(_index) : str_base(_index) constructor {
	flags			= STR_FLAG_PERSISTENT;
	
	// 
	controlIcons	= ds_map_create();
	
	/// @description 
	///	
	///	
	create_event = function(){
		if (room != rm_init)
			return; // Prevents a call to this function from executing outside of the game's initialization.
			
		var _inputs = global.settings.inputs;
		set_control_icon(ICONUI_INTERACT, _inputs[STNG_INPUT_INTERACT]);
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
	///	Create a struct containing information about a key/gamepad binding's graphical representation on the
	/// ui whenever the binding needs to be shown to the user to describe its functionality in the current
	/// context. When the struct already exists, it will simply update the contents for the icon data if the
	/// key or gamepad bindings happen to differ from their previous values, respectively.
	///	
	///	@param {Any}	key			What will be used to reference the control icon data within the controlIcons map.
	/// @param {Real}	keyBinding	Keyboard constant that will be used to get its icon index.
	/// @param {Real}	padBinding	(Optional) Gamepad constant that will be used to get its icon index.
	set_control_icon = function(_key, _keyBinding, _padBinding = ICONUI_BINDING_NONE){
		var _value = ds_map_find_value(controlIcons, _key);
		if (is_undefined(_value)){ // Create new struct to manage the control ui icon pair.
			ds_map_add(controlIcons, _key, {
				keyBinding	: _keyBinding,
				keyIcon		: get_keyboard_icon(_keyBinding),
				padBinding	: _padBinding,
				padIcon		: get_gamepad_icon(_padBinding),
			});
			return;
		}
		
		// The struct already exists for the current control icon pair, so they will be updated should the
		// bindings provided in the argument parameters be different from what the icons currently represent.
		with(_value){
			if (keyBinding != _keyBinding) { keyIcon = get_keyboard_icon(_keyBinding); }
			if (padBinding != _padBinding) { padIcon = get_gamepad_icon(_padBinding); }
		}
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