#region General Macro Initializations

// Virtual keyboard constants for all keyboard keys that don't have built-in vk constants already.
#macro	vk_0							0x30	// Top-row number keys
#macro	vk_1							0x31
#macro	vk_2							0x32
#macro	vk_3							0x33
#macro	vk_4							0x34
#macro	vk_5							0x35
#macro	vk_6							0x36
#macro	vk_7							0x37
#macro	vk_8							0x38
#macro	vk_9							0x39
#macro	vk_a							0x41	// Alphabet keys
#macro	vk_b							0x42
#macro	vk_c							0x43
#macro	vk_d							0x44
#macro	vk_e							0x45
#macro	vk_f							0x46
#macro	vk_g							0x47
#macro	vk_h							0x48
#macro	vk_i							0x49
#macro	vk_j							0x4A
#macro	vk_k							0x4B
#macro	vk_l							0x4C
#macro	vk_m							0x4D
#macro	vk_n							0x4E
#macro	vk_o							0x4F
#macro	vk_p							0x50
#macro	vk_q							0x51
#macro	vk_r							0x52
#macro	vk_s							0x53
#macro	vk_t							0x54
#macro	vk_u							0x55
#macro	vk_v							0x56
#macro	vk_w							0x57
#macro	vk_x							0x58
#macro	vk_y							0x59
#macro	vk_z							0x5A
#macro	vk_capslock						0x14	// All remaining keys
#macro	vk_numberlock					0x90
#macro	vk_scrolllock					0x91
#macro	vk_semicolon					0xBA	// Also ":"
#macro	vk_equal						0xBB	// Also "+"
#macro	vk_comma						0xBC	// Also "<"
#macro	vk_underscore					0xBD	// Also "-"
#macro	vk_period						0xBE	// Also ">"
#macro	vk_forwardslash					0xBF	// Also "?"
#macro	vk_tilde						0xC0	// Also "`"
#macro	vk_openbracket					0xDA	// Also "{"
#macro	vk_backslash					0xDC	// Also "|"
#macro	vk_closebracket					0xDD	// Also "}"
#macro	vk_quotation					0xDE	// Also "'"

// The value that equates to one second of real-time in the game's units. An exmaple would be an entity with
// a speed value of 1.0 would move roughly 60 pixels per second.
#macro	GAME_TARGET_FPS					60.0

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
#macro	GAME_FLAG_PLAYTIME_ACTIVE		0x01000000	// Other impotant flags
#macro	GAME_FLAG_TRANSITION_ACTIVE		0x02000000
#macro	GAME_FLAG_TEXTBOX_OPEN			0x04000000
#macro	GAME_FLAG_GAMEPAD_ACTIVE		0x08000000
#macro	GAME_FLAG_IN_GAME				0x10000000	// Main game state flags
#macro	GAME_FLAG_MENU_OPEN				0x20000000
#macro	GAME_FLAG_CUTSCENE_ACTIVE		0x40000000
#macro	GAME_FLAG_PAUSED				0x80000000

// Macros that allow the state of a given flag within global.flags to be checked; returning either a 0 AKA "false"
// or the value of the flag itself which is non-zero AKA "true".
#macro	GAME_IS_PLAYTIME_ACTIVE			((global.flags & GAME_FLAG_PLAYTIME_ACTIVE)		!= 0)
#macro	GAME_IS_TRANSITION_ACTIVE		((global.flags & GAME_FLAG_TRANSITION_ACTIVE)	!= 0)
#macro	GAME_IS_TEXTBOX_OPEN			((global.flags & GAME_FLAG_TEXTBOX_OPEN)		!= 0)
#macro	GAME_IS_GAMEPAD_ACTIVE			((global.flags & GAME_FLAG_GAMEPAD_ACTIVE)		!= 0)
#macro	GAME_IS_IN_GAME					((global.flags & GAME_FLAG_IN_GAME)				!= 0)
#macro	GAME_IS_MENU_OPEN				((global.flags & GAME_FLAG_MENU_OPEN)			!= 0)
#macro	GAME_IS_CUTSCENE_ACTIVE			((global.flags & GAME_FLAG_CUTSCENE_ACTIVE)		!= 0)
#macro	GAME_IS_PAUSED					((global.flags & GAME_FLAG_PAUSED)				!= 0)

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
#macro	MENU_KEY_RIGHT					keyboard_check(global.settings.inputs[STNG_INPUT_MENU_RIGHT])
#macro	MENU_KEY_LEFT					keyboard_check(global.settings.inputs[STNG_INPUT_MENU_LEFT])
#macro	MENU_KEY_UP						keyboard_check(global.settings.inputs[STNG_INPUT_MENU_UP])
#macro	MENU_KEY_DOWN					keyboard_check(global.settings.inputs[STNG_INPUT_MENU_DOWN])
#macro	MENU_KEY_SELECT					keyboard_check(global.settings.inputs[STNG_INPUT_SELECT])
#macro	MENU_KEY_RETURN					keyboard_check(global.settings.inputs[STNG_INPUT_RETURN])
#macro	MENU_KEY_FILE_DELETE			keyboard_check(global.settings.inputs[STNG_INPUT_FILE_DELETE])
#macro	MENU_KEY_TBOX_ADVANCE			keyboard_check(global.settings.inputs[STNG_INPUT_TBOX_ADVANCE])
#macro	MENU_KEY_TBOX_LOG				keyboard_check(global.settings.inputs[STNG_INPUT_TBOX_LOG])

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
#macro	MENU_PAD_RIGHT					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_MENU_RIGHT		+ 1])
#macro	MENU_PAD_LEFT					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_MENU_LEFT		+ 1])
#macro	MENU_PAD_UP						gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_MENU_UP		+ 1])
#macro	MENU_PAD_DOWN					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_MENU_DOWN		+ 1])
#macro	MENU_PAD_SELECT					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_SELECT			+ 1])
#macro	MENU_PAD_RETURN					gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_RETURN			+ 1])
#macro	MENU_PAD_FILE_DELETE			gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_FILE_DELETE	+ 1])
#macro	MENU_PAD_TBOX_ADVANCE			gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_TBOX_ADVANCE	+ 1])
#macro	MENU_PAD_TBOX_LOG				gamepad_button_check(global.gamepadID, global.settings.inputs[STNG_INPUT_TBOX_LOG		+ 1])

// 
#macro	STNG_AUDIO_MASTER				0
#macro	STNG_AUDIO_MUSIC				1
#macro	STNG_AUDIO_SOUNDS				2
#macro	TOTAL_VOLUME_OPTIONS			3

// 
#macro	STNG_INPUT_GAME_RIGHT			0
#macro	STNG_INPUT_GAME_LEFT			2
#macro	STNG_INPUT_GAME_UP				4
#macro	STNG_INPUT_GAME_DOWN			6
#macro	STNG_INPUT_INTERACT				8
#macro	STNG_INPUT_SPRINT				10
#macro	STNG_INPUT_READYWEAPON			12
#macro	STNG_INPUT_FLASHLIGHT			14
#macro	STNG_INPUT_USEWEAPON			16
#macro	STNG_INPUT_MENU_RIGHT			18
#macro	STNG_INPUT_MENU_LEFT			20
#macro	STNG_INPUT_MENU_UP				22
#macro	STNG_INPUT_MENU_DOWN			24
#macro	STNG_INPUT_SELECT				26
#macro	STNG_INPUT_RETURN				28
#macro	STNG_INPUT_FILE_DELETE			30
#macro	STNG_INPUT_TBOX_ADVANCE			32
#macro	STNG_INPUT_TBOX_LOG				34

#endregion General Macro Initializations

#region Game Manager Global and Local Variable Initializations

// Stores a copy of the application surface for any post-processing effects that require the application surface
// that occur outside of the draw GUI events. Otherwise, it will draw itself to itself which makes no sense and
// nothing will be rendered.
global.worldSurface		= -1;

// Variables for allowing frame-independent movement as well as two values that track the application's total
// uptime and current playtime, respectively. Fraction values for both are stored seperately as values between
// 0 and the game's target FPS value.
global.deltaTime		= 0.0;
global.totalPlaytime	= 0;
global.totalUptime		= 0;
playtimeFraction		= 0.0;
uptimeFraction			= 0.0;

// A variable containing various flags that affect the game on a global scale. This includes things like gamepad
// input activity, game states, and so on.
global.flags			= GAME_FLAG_PAUSED;

// A grid storing the id values for all existing static and dynamic entities within the current room alongside
// their current y positions. Those y positions will be used to sort their drawn from top to bottom on the screen.
global.sortOrder		= ds_grid_create(2, 0);

// Struct containings all of the various settings for the game that can be altered by the player. These altered
// values will be saved from "settings.ini" and loaded from there as well on all subsequent start-ups.
global.settings			= {
	// --- Video Settings --- //
	windowScale			: 4,
	
	// --- Audio Setting Array --- //
	audio				: [
	
		1.0,			// Master
		0.9,			// Sound Effects
		0.7				// Music
		
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
		gp_shoulderl,
		vk_space,		// Ready Equipped Weapon
		gp_shoulderr,
		vk_f,			// Toggle Flashlight (If Equipped)
		gp_face4,
		vk_z,			// Uses Equipped Weapon (Only When Readied)
		gp_face1,
		
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
		vk_z,			// Advance Textbox/Skip Typing Animation
		gp_face1,
		vk_space,		// Open Current Conversation Log
		gp_face4,
		
	],
	
	// --- Other Gamepad Settings --- //
	stickDeadzone		: 0.15,
	triggerThreshold	: 0.5,
};

// Stores the device ID for the gamepad that is currently connected to the game so its input can be polled.
global.gamepadID		= -1;

// Uniforms for the lighting shader that will allow the properties of the shader to be changed on-the-fly as
// required for the current area in the game.
uLightColor				= shader_get_uniform(shd_lighting, "color");
uLightBrightness		= shader_get_uniform(shd_lighting, "brightness");
uLightSaturation		= shader_get_uniform(shd_lighting, "saturation");
uLightContrast			= shader_get_uniform(shd_lighting, "contrast");
uLightTexture			= shader_get_sampler_index(shd_lighting, "lightTex");

#endregion Game Manager Global and Local Variable Initializations

// These calls are for testing purposes
load_item_data("items.dat");
inventory_initialize(GAME_FLAG_CMBTDIFF_STANDARD);