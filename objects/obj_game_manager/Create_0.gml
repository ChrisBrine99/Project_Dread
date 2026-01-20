#region General Macro Initializations

// Values for the flags found within global.flags. They enable and disable certain aspects of the game on a
// global scale as required.
#macro	GAME_FLAG_CMBTDIFF_FORGIVING	0x00000001	// Combat difficulty flags
#macro	GAME_FLAG_CMBTDIFF_STANDARD		0x00000002
#macro	GAME_FLAG_CMBTDIFF_PUNISHING	0x00000004
#macro	GAME_FLAG_CMBTDIFF_NIGHTMARE	0x00000008
#macro	GAME_FLAG_CMBTDIFF_ONELIFE		0x00000010
#macro	GAME_FLAG_PUZZDIFF_FORGIVING	0x00000020	// Puzzle difficulty flags
#macro	GAME_FLAG_PUZZDIFF_STANDARD		0x00000040
#macro	GAME_FLAG_PUZZDIFF_PUNISHING	0x00000080
#macro	GAME_FLAG_PLAYTIME_ACTIVE		0x00800000	// Other important flags
#macro	GAME_FLAG_TRANSITION_ACTIVE		0x01000000
#macro	GAME_FLAG_ROOM_WARP				0x02000000
#macro	GAME_FLAG_TEXTBOX_OPEN			0x04000000
#macro	GAME_FLAG_GAMEPAD_ACTIVE		0x08000000
#macro	GAME_FLAG_IN_GAME				0x10000000	// Main game state flags
#macro	GAME_FLAG_MENU_OPEN				0x20000000
#macro	GAME_FLAG_CUTSCENE_ACTIVE		0x40000000
#macro	GAME_FLAG_PAUSED				0x80000000

// Macros that allow the state of a given flag within global.flags to be checked; returning either a 0 AKA 
// "false" or the value of the flag itself which is non-zero AKA "true".
#macro	GAME_IS_CMBTDIFF_FORGIVING		((global.flags & GAME_FLAG_CMBTDIFF_FORGIVING)	!= 0)
#macro	GAME_IS_CMBTDIFF_STANDARD		((global.flags & GAME_FLAG_CMBTDIFF_STANDARD)	!= 0)
#macro	GAME_IS_CMBTDIFF_PUNISHING		((global.flags & GAME_FLAG_CMBTDIFF_PUNISHING)	!= 0)
#macro	GAME_IS_CMBTDIFF_NIGHTMARE		((global.flags & GAME_FLAG_CMBTDIFF_NIGHTMARE)	!= 0)
#macro	GAME_IS_CMBTDIFF_ONELIFE		((global.flags & GAME_FLAG_CMBTDIFF_ONELIFE)	!= 0)
#macro	GAME_IS_PUZZDIFF_FORGIVING		((global.flags & GAME_FLAG_PUZZDIFF_FORGIVING)	!= 0)
#macro	GAME_IS_PUZZDIFF_STANDARD		((global.flags & GAME_FLAG_PUZZDIFF_STANDARD)	!= 0)
#macro	GAME_IS_PUZZDIFF_PUNISHING		((global.flags & GAME_FLAG_PUZZDIFF_PUNISHING)	!= 0)
#macro	GAME_IS_PLAYTIME_ACTIVE			((global.flags & GAME_FLAG_PLAYTIME_ACTIVE)		!= 0)
#macro	GAME_IS_TRANSITION_ACTIVE		((global.flags & GAME_FLAG_TRANSITION_ACTIVE)	!= 0)
#macro	GAME_IS_ROOM_WARP_OCCURRING		((global.flags & GAME_FLAG_ROOM_WARP)			!= 0)
#macro	GAME_IS_TEXTBOX_OPEN			((global.flags & GAME_FLAG_TEXTBOX_OPEN)		!= 0)
#macro	GAME_IS_GAMEPAD_ACTIVE			((global.flags & GAME_FLAG_GAMEPAD_ACTIVE)		!= 0)
#macro	GAME_IS_IN_GAME					((global.flags & GAME_FLAG_IN_GAME)				!= 0)
#macro	GAME_IS_MENU_OPEN				((global.flags & GAME_FLAG_MENU_OPEN)			!= 0)
#macro	GAME_IS_CUTSCENE_ACTIVE			((global.flags & GAME_FLAG_CUTSCENE_ACTIVE)		!= 0)
#macro	GAME_IS_PAUSED					((global.flags & GAME_FLAG_PAUSED)				!= 0)

// Macros for referencing the instance IDs for all compile-time singletons.
#macro	GAME_MANAGER					global.sInstances[? obj_game_manager]
#macro	PLAYER							global.sInstances[? obj_player]
#macro	CUTSCENE_MANAGER				global.sInstances[? str_cutscene_manager]
#macro	CONTROL_UI_MANAGER				global.sInstances[? str_control_ui_manager]
#macro	CAMERA							global.sInstances[? str_camera]
#macro	TEXTBOX							global.sInstances[? str_textbox]
#macro	TEXTBOX_LOG						global.sInstances[? str_textbox_log]
#macro	SCREEN_FADE						global.sInstances[? str_screen_fade]

// Macros for referencing the instance IDs of all runtime singletons. These will return "noone" if no 
// instance exists for these special singleton types.
#macro	MENU_INVENTORY					global.sInstances[? str_inventory_menu]
#macro	MENU_ITEMS						global.sInstances[? str_item_menu]
#macro	MENU_NOTES						global.sInstances[? str_note_menu]
#macro	MENU_MAPS						global.sInstances[? str_map_menu]

// Macros for retrieving the state of a given input binding on the keyboard. It simply returns if the key is
// currently held down or not, and logic for key presses/releases is done within a controllable object using
// their "inputFlags" and "prevInputFlags" variables.
#macro	GAME_KEY_RIGHT					keyboard_check(global.settings.inputs[STNG_INPUT_GAME_RIGHT])
#macro	GAME_KEY_LEFT					keyboard_check(global.settings.inputs[STNG_INPUT_GAME_LEFT])
#macro	GAME_KEY_UP						keyboard_check(global.settings.inputs[STNG_INPUT_GAME_UP])
#macro	GAME_KEY_DOWN					keyboard_check(global.settings.inputs[STNG_INPUT_GAME_DOWN])
#macro	GAME_KEY_INTERACT				keyboard_check(global.settings.inputs[STNG_INPUT_INTERACT])
#macro	GAME_KEY_SPRINT					keyboard_check(global.settings.inputs[STNG_INPUT_SPRINT])
#macro	GAME_KEY_READYWEAPON			keyboard_check(global.settings.inputs[STNG_INPUT_READYWEAPON])
#macro	GAME_KEY_FLASHLIGHT				keyboard_check(global.settings.inputs[STNG_INPUT_FLASHLIGHT])
#macro	GAME_KEY_USEWEAPON				keyboard_check(global.settings.inputs[STNG_INPUT_USEWEAPON])
#macro	GAME_KEY_RELOADWEAPON			keyboard_check(global.settings.inputs[STNG_INPUT_RELOADWEAPON])
#macro	GAME_KEY_CHANGE_AMMO			keyboard_check(global.settings.inputs[STNG_INPUT_CHANGE_AMMO])
#macro	MENU_KEY_RIGHT					keyboard_check(global.settings.inputs[STNG_INPUT_MENU_RIGHT])
#macro	MENU_KEY_LEFT					keyboard_check(global.settings.inputs[STNG_INPUT_MENU_LEFT])
#macro	MENU_KEY_UP						keyboard_check(global.settings.inputs[STNG_INPUT_MENU_UP])
#macro	MENU_KEY_DOWN					keyboard_check(global.settings.inputs[STNG_INPUT_MENU_DOWN])
#macro	MENU_KEY_SELECT					keyboard_check(global.settings.inputs[STNG_INPUT_SELECT])
#macro	MENU_KEY_RETURN					keyboard_check(global.settings.inputs[STNG_INPUT_RETURN])
#macro	MENU_KEY_FILE_DELETE			keyboard_check(global.settings.inputs[STNG_INPUT_FILE_DELETE])
#macro	MENU_KEY_TBOX_ADVANCE			keyboard_check(global.settings.inputs[STNG_INPUT_TBOX_ADVANCE])
#macro	MENU_KEY_TBOX_LOG				keyboard_check(global.settings.inputs[STNG_INPUT_TBOX_LOG])
#macro	MENU_KEY_INV_RIGHT				keyboard_check(global.settings.inputs[STNG_INPUT_INV_RIGHT])
#macro	MENU_KEY_INV_LEFT				keyboard_check(global.settings.inputs[STNG_INPUT_INV_LEFT])
#macro	GAME_KEY_ITEM_MENU				keyboard_check(global.settings.inputs[STNG_INPUT_ITEM_MENU])
#macro	GAME_KEY_NOTE_MENU				keyboard_check(global.settings.inputs[STNG_INPUT_NOTE_MENU])
#macro	GAME_KEY_MAP_MENU				keyboard_check(global.settings.inputs[STNG_INPUT_MAP_MENU])
#macro	GAME_KEY_PAUSE_MENU				keyboard_check(global.settings.inputs[STNG_INPUT_PAUSE_MENU])

// These macros are similar to above, but they are for checking gamepad inputs instead of the keyboard.
#macro	GAME_PAD_RIGHT					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_GAME_RIGHT		+ 1])
#macro	GAME_PAD_LEFT					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_GAME_LEFT		+ 1])
#macro	GAME_PAD_UP						gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_GAME_UP		+ 1])
#macro	GAME_PAD_DOWN					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_GAME_DOWN		+ 1])
#macro	GAME_PAD_INTERACT				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_INTERACT		+ 1])
#macro	GAME_PAD_SPRINT					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_SPRINT			+ 1])
#macro	GAME_PAD_READYWEAPON			gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_READYWEAPON	+ 1])
#macro	GAME_PAD_FLASHLIGHT				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_FLASHLIGHT		+ 1])
#macro	GAME_PAD_USEWEAPON				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_USEWEAPON		+ 1])
#macro	GAME_PAD_RELOADWEAPON			gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_RELOADWEAPON	+ 1])
#macro	GAME_PAD_CHANGE_AMMO			gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_CHANGE_AMMO	+ 1])
#macro	MENU_PAD_RIGHT					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_MENU_RIGHT		+ 1])
#macro	MENU_PAD_LEFT					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_MENU_LEFT		+ 1])
#macro	MENU_PAD_UP						gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_MENU_UP		+ 1])
#macro	MENU_PAD_DOWN					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_MENU_DOWN		+ 1])
#macro	MENU_PAD_SELECT					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_SELECT			+ 1])
#macro	MENU_PAD_RETURN					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_RETURN			+ 1])
#macro	MENU_PAD_FILE_DELETE			gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_FILE_DELETE	+ 1])
#macro	MENU_PAD_TBOX_ADVANCE			gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_TBOX_ADVANCE	+ 1])
#macro	MENU_PAD_TBOX_LOG				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_TBOX_LOG		+ 1])
#macro	MENU_PAD_INV_RIGHT				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_INV_RIGHT		+ 1])
#macro	MENU_PAD_INV_LEFT				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_INV_LEFT		+ 1])
#macro	GAME_PAD_ITEM_MENU				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_ITEM_MENU		+ 1])
#macro	GAME_PAD_NOTE_MENU				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_NOTE_MENU		+ 1])
#macro	GAME_PAD_MAP_MENU				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_MAP_MENU		+ 1])
#macro	GAME_PAD_PAUSE_MENU				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_PAUSE_MENU		+ 1])

// Macros for what each bit in the global.settings struct's "flags" variable represent in the context of the 
// game's currently active settings when a given flag is set.
#macro	STNG_FLAG_VSYNC					0x00000001	// Video flags
#macro	STNG_FLAG_FULL_SCREEN			0x00000002
#macro	STNG_FLAG_QUANTIZATION			0x00000004
#macro	STNG_FLAG_DITHERING				0x00000008
#macro	STNG_FLAG_SCANLINES				0x00000010
#macro	STNG_FLAG_MUSIC					0x00000020	// Audio flags
#macro	STNG_FLAG_SPRINT_TOGGLE			0x00000040	// Input flags
#macro	STNG_FLAG_AIM_TOGGLE			0x00000080
#macro	STNG_FLAG_VIBRATION				0x00000100	// Gamepad flags

// Macros for checking if a given flag in the global.settings struct's "flags" variable is set or cleared.
#macro	STNG_IS_VSYNC_ON				((global.settings.flags & STNG_FLAG_VSYNC)			!= 0)
#macro	STNG_IS_FULL_SCREEN				((global.settings.flags & STNG_FLAG_FULL_SCREEN)	!= 0)
#macro	STNG_IS_QUANTIZATION_ON			((global.settings.flags & STNG_FLAG_QUANTIZATION)	!= 0)
#macro	STNG_IS_DITHERING_ON			((global.settings.flags & STNG_FLAG_DITHERING)		!= 0)
#macro	STNG_ARE_SCANLINES_ON			((global.settings.flags & STNG_FLAG_SCANLINES)		!= 0)
#macro	STNG_IS_MUSIC_ON				((global.settings.flags & STNG_FLAG_MUSIC)			!= 0)
#macro	STNG_IS_AIM_INPUT_TOGGLE		((global.settings.flags & STNG_FLAG_AIM_TOGGLE)		!= 0)
#macro	STNG_IS_SPRINT_INPUT_TOGGLE		((global.settings.flags & STNG_FLAG_SPRINT_TOGGLE)	!= 0)
#macro	STNG_IS_VIBRATION_ACTIVE		((global.settings.flags & STNG_FLAG_VIBRATION)		!= 0)

// Macros for the index values within the global.setting struct volume array. They each correspond to a 
// group of sounds that can have their volume adjusted independently of the other values (As well as the
// main master volume value at index 0).
#macro	STNG_AUDIO_MASTER				0
#macro	STNG_AUDIO_GAME_SOUNDS			1
#macro	STNG_AUDIO_MENU_SOUNDS			2
#macro	STNG_AUDIO_MUSIC				3
#macro	STNG_AUDIO_AMBIENCE				4
#macro	TOTAL_VOLUME_OPTIONS			5

// Macros for the index values within the global.settings struct input binding array. There are two values 
// for each input: the keyboard binding, and the gamepad binding. So, each macro is an even number and is 
// incremented in order to get the input's gamepad equivalent.
#macro	STNG_INPUT_GAME_RIGHT			0
#macro	STNG_INPUT_GAME_LEFT			2
#macro	STNG_INPUT_GAME_UP				4
#macro	STNG_INPUT_GAME_DOWN			6
#macro	STNG_INPUT_INTERACT				8
#macro	STNG_INPUT_SPRINT				10
#macro	STNG_INPUT_READYWEAPON			12
#macro	STNG_INPUT_USEWEAPON			14
#macro	STNG_INPUT_RELOADWEAPON			16
#macro	STNG_INPUT_CHANGE_AMMO			18
#macro	STNG_INPUT_FLASHLIGHT			20
#macro	STNG_INPUT_MENU_RIGHT			22
#macro	STNG_INPUT_MENU_LEFT			24
#macro	STNG_INPUT_MENU_UP				26
#macro	STNG_INPUT_MENU_DOWN			28
#macro	STNG_INPUT_SELECT				30
#macro	STNG_INPUT_RETURN				32
#macro	STNG_INPUT_FILE_DELETE			34
#macro	STNG_INPUT_TBOX_ADVANCE			36
#macro	STNG_INPUT_TBOX_LOG				38
#macro	STNG_INPUT_INV_LEFT				40
#macro	STNG_INPUT_INV_RIGHT			42
#macro	STNG_INPUT_ITEM_MENU			44
#macro	STNG_INPUT_NOTE_MENU			46
#macro	STNG_INPUT_MAP_MENU				48
#macro	STNG_INPUT_PAUSE_MENU			50

#endregion General Macro Initializations

#region Game Manager Global and Local Variable Initializations

// The map that manages the instance IDs and references to all existing special objects within the game. 
// These objects are "special" in that only one instance may exist of any of them during runtime, and 
// attempts to create multiples instances of them will fail when utilizing the proper creation functions. 
// They also cannot be deleted during runtime and attempts to do so will also fail when utilizing the proper 
// deletion functions.
global.sInstances		= ds_map_create();

// Stores a copy of the application surface for any post-processing effects that require the application 
// surface that occur outside of the draw GUI events. Otherwise, it will draw itself to itself which makes 
// no sense and nothing will be rendered.
global.worldSurface		= -1;

// Surface that contains the shadows casted by entities onto the floor beneath them. The mask layer will
// store an ID for the tile layer of all walls in the room which will be used to mask out any shadows that
// might cast onto these walls if their shape doesn't match the entity's collision bounds.
global.shadowSurface	= -1;
maskLayerID				= -1;

// Variables for allowing frame-independent movement as well as two values that track the application's 
// total uptime and current playtime, respectively. Fraction values for both are stored seperately as values
// between 0 and the game's target FPS value.
global.deltaTime		= 0.0;
global.totalPlaytime	= 0;
global.totalUptime		= 0;
playtimeFraction		= 0.0;
uptimeFraction			= 0.0;

// A variable containing various flags that affect the game on a global scale. This includes things like 
// gamepad input activity, game states, and so on.
global.flags			= GAME_FLAG_PAUSED;

// A grid storing the id values for all existing static and dynamic entities within the current room 
// alongside their current y positions. Those y positions will be used to sort their drawn from top to 
// bottom on the screen.
global.sortOrder		= ds_grid_create(2, 0);

// Struct containings all of the various settings for the game that can be altered by the player. These 
// altered values will be saved from "settings.ini" and loaded from there as well on all subsequent start-ups.
global.settings			= {
	// --- Holds Flags Used in All Settting Groups --- //
	flags				: STNG_FLAG_QUANTIZATION | STNG_FLAG_DITHERING | STNG_FLAG_SCANLINES |
							STNG_FLAG_MUSIC | STNG_FLAG_VIBRATION, // These flags are set by default.
	
	// --- Video Settings --- //
	windowScale			: 4,
	
	// --- Audio Setting Array --- //
	audio				: [
	
		1.0,			// Master
		0.9,			// In-Game Sounds
		0.8,			// Menu/UI Sounds
		0.7,			// Music
		0.7				// Ambience
		
	],
	
	// --- Input Setting Array --- //
	inputs				: [
	
		// --- Inputs During Standard Gameplay (Keyboard and Gamepad Interwoven) --- //
		vk_right,		// Move Character Right
		gp_padr,
		vk_left,		// Move Character Left
		gp_padl,
		vk_up,			// Move Character Up
		gp_padu,
		vk_down,		// Move Character Down
		gp_padd,
		vk_z,			// Interact with Environment
		gp_face1,
		vk_shift,		// Activate Sprinting
		gp_shoulderlb,
		vk_space,		// Ready Equipped Weapon
		gp_shoulderrb,
		vk_z,			// Uses Equipped Weapon (Only When Readied)
		gp_face1,
		vk_r,			// Reloads Equipped Weapon (If Possible and Only When Readied)
		gp_face3,
		vk_x,			// Switches currently used ammunition
		gp_face2,
		vk_f,			// Toggle Flashlight (If Equipped)
		gp_face4,
		
		// --- Inputs When Navigating Menus (Keyboard and Gamepad Interwoven) --- //
		vk_right,		// Move Menu Cursor Right
		gp_padr,
		vk_left,		// Move Menu Cursor Left
		gp_padl,
		vk_up,			// Move Menu Cursor Up
		gp_padu,
		vk_down,		// Move Menu Cursor Down
		gp_padd,
		vk_z,			// Select Highlight Menu Option
		gp_face1,
		vk_x,			// Revert To Previous Menu/De-select Menu Option
		gp_face2,
		vk_d,			// Delete Save Data of Highlighted Save
		gp_face4,
		
		// --- Inputs for the Textbox (Keyboard and Gamepad Interwoven) --- //
		vk_z,			// Advance Textbox/Skip Typing Animation
		gp_face1,
		vk_x,			// Open Current Conversation Log
		gp_face4,
		
		// --- Inputs for the Inventory Menu (Keyboard and Gamepad Interwoven) --- //
		vk_c,			// Tabbing to the section left of the current one
		gp_shoulderlb,
		vk_v,			// Tabbing to the section right of the current one
		gp_shoulderrb,
		
		// --- Inputs for Opening Menus During Gameplay (Keyboard and Gamepad Interwoven) --- //
		vk_tab,			// Shortcut for item menu
		gp_select,
		vk_n,			// Shortcut for note menu
		gp_shoulderl,
		vk_m,			// Shortcut for map menu
		gp_shoulderr,
		vk_escape,		// Shortcut for pause menu
		gp_start,
	],
	
	// --- Other Gamepad Settings --- //
	stickDeadzone		: 0.15,
	triggerThreshold	: 0.5,
};

// Struct containing information and functionality regarding the color fade shader effect.
global.colorFadeShader = {
	// Stores the color being used for the shader's effect in both hexidecimal and individual RGB format. 
	// This allows the hex value to check if a color update should occur to prevent constantly having to
	// convert a color if that color is already being used with the shader.
	curColorHex			: COLOR_BLACK,
	curColorRGB			: [0.0, 0.0, 0.0],
	
	// Get and store the uniform for shader so the color utilized can be adjusted as required.
	uFadeColor			: shader_get_uniform(shd_color_fade, "fadeColor"),
	
	/// @description 
	///	Call this to activate the shader and set its uniform vector to match the color the effect will use.
	/// If the effect is already active when this function is called, it will simply exit early. Note that 
	/// calling "shader_reset" at some point after calling this function is REQUIRED!!!
	///	
	/// @param {Real}	color	Determines the color that this shader effect will utilize.
	activate_shader		: function(_color){
		if (shader_current() == shd_color_fade)
			return;
			
		shader_set(shd_color_fade);
		set_effect_color(_color);
	},
	
	/// @description 
	///	Sets the color that will be used for the shader's effect.
	///	
	/// @param {Real}	color	Determines the color that this shader effect will utilize.
	set_effect_color	: function(_color){
		if (curColorHex == _color){
			shader_set_uniform_f_array(uFadeColor, curColorRGB);
			return; // Don't set a color if it matches the one that is currently in use.
		}
		
		// Copy the hex code for the color, and then split that color into its indiviual RGB components that
		// range between 0.0 and 1.0 so the shader can properly utilize each value.
		curColorHex	= _color;
		curColorRGB = [
			color_get_red(_color)	/ 255.0,
			color_get_green(_color) / 255.0,
			color_get_blue(_color)	/ 255.0
		];
		shader_set_uniform_f_array(uFadeColor, curColorRGB);
	},
};

// Stores the device ID for the gamepad that is currently connected to the game so its input can be polled.
global.gamepadID		= -1;

// Uniforms for the lighting shader that will allow the properties of the shader to be changed on-the-fly as
// required for the current area in the game.
uLightColor				= shader_get_uniform(shd_lighting,			"color");
uLightBrightness		= shader_get_uniform(shd_lighting,			"brightness");
uLightSaturation		= shader_get_uniform(shd_lighting,			"saturation");
uLightContrast			= shader_get_uniform(shd_lighting,			"contrast");
uLightTexture			= shader_get_sampler_index(shd_lighting,	"lightTex");

// Uniforms for the screen blurring shader that will allow the properties of the shader to be altered as
// needed to achieve the desired effect (Note that UI elements will not be affected by the blur).
uTexelSize				= shader_get_uniform(shd_screen_blur,		"texelSize");
uBlurDirection			= shader_get_uniform(shd_screen_blur,		"blurDirection");
uBlurSteps				= shader_get_uniform(shd_screen_blur,		"blurSteps");
uSigma					= shader_get_uniform(shd_screen_blur,		"sigma");

// Uniforms for the shader that is responsible for applying the quantization, dithering, and scanline effects
// onto the game's image.
uScanlineFactor			= shader_get_uniform(shd_retro_effects,		"scanlineFactor");
uQuantizeLevel			= shader_get_uniform(shd_retro_effects,		"quantizeLevel");
uDitherMatrix			= shader_get_uniform(shd_retro_effects,		"ditherMatrix");
uViewportSize			= shader_get_uniform(shd_retro_effects,		"viewportSize");
uQuantizationActive		= shader_get_uniform(shd_retro_effects,		"quantizationActive");
uDitheringActive		= shader_get_uniform(shd_retro_effects,		"ditheringActive");
uScanlinesActive		= shader_get_uniform(shd_retro_effects,		"scanlinesActive");

// Stores the current offset for the screen-wide noise effect. This allows the game to pause the effect if it
// is ever required since without these variables the draw call would constantly be setting new random numbers
// for each offset between 0 and 63.
xNoiseOffset			= 0;
yNoiseOffset			= 0;

// Variables for storing data regarding a room transition. The first value is simply the index for the room
// that should be loaded next. The second is a map containing the instances that should move to the next room.
targetRoom				= noone;
instancesToWarp			= ds_map_create();

#endregion Game Manager Global and Local Variable Initializations

#region Game Manager Local Function Initializations

/// @description 
///	Adds a given instance to the map of instances that will warp to the target room together. Each instance
/// can be given a unique position, and all will temporarily be set to persistent during the warping process.
///	
///	@param {Id.Instance}	id			The unique value given to the instance in question.
/// @param {Real}			targetX		Position along the x-axis within the target room to set the instance's x position to.
/// @param {Real}			targetY		Position along the y-axis within the target room to set the instance's y position to.
add_instance_to_warp = function(_id, _targetX, _targetY){
	var _key = ds_map_find_value(instancesToWarp, _id);
	if (!is_undefined(_key)) // Don't try to add the same instance twice.
		return;
	
	var _persistent = false;
	with(_id){ // Store whether or not the isntance was previously persistent before setting it to true. 
		_persistent = persistent;
		persistent	= true;
	}
	
	// Store the target position for the instance to warp to and whether the object was persistent based on the
	// value stored in the local "_persistent" variable. This is required since warping objects will be set to
	// temporary persistence so they aren't destroyed during the actual room transition.
	ds_map_add(instancesToWarp, _id, {
		targetX			: _targetX,
		targetY			: _targetY,
		wasPersistent	: _persistent
	});
}

#endregion Game Manager Local Function Initializations

#region Debug Variable Initializations

// Stores a list of structs that are lines rendered to the screen for a limited amount of time or indefintely
// if that is required. Useful for tracking hitscan collision paths or distances between objects and so on.
debugLines		= ds_list_create();

// Stores the number of dynamic and static entities currently being drawn in the current room, respectively.
numDynamicDrawn	= 0;
numStaticDrawn	= 0;

#endregion Debug Variable Initialzations

#region Debug Function Initializations

/// @description 
///	Creates a line within the world from the provided starting coordinates to the provided ending coordinates
/// for the lifetime set in the final parameter (60 units = 1 second of real-time). Useful for showing hitscan
/// collision lines and such.
///	
///	@param {Real}	xStart		Origin of the line along the current room's x axis.
/// @param {Real}	yStart		Origin of the line along the current room's y axis.
/// @param {Real}	xEnd		Endpoint of the line along the current room's x axis.
/// @param {Real}	yEnd		Endpoint of the line along the current room's y axis.
/// @param {Real}	lifetime	How long the line will be displayed for in units.
add_debug_line = function(_xStart, _yStart, _xEnd, _yEnd, _lifetime){
	ds_list_add(debugLines, {
		xStart		: _xStart,
		yStart		: _yStart,
		xEnd		: _xEnd,
		yEnd		: _yEnd,
		curLifetime	: _lifetime,
		lifetime	: max(_lifetime, 1),
	});
}

#endregion Debug Function Initializations

load_item_data("items.dat");
item_inventory_initialize(GAME_FLAG_CMBTDIFF_STANDARD);
show_debug_overlay(false);