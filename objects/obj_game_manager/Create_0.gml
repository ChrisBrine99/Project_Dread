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
#macro	GAME_KEY_RIGHT					keyboard_check(global.settings.gameKeyRight)
#macro	GAME_KEY_LEFT					keyboard_check(global.settings.gameKeyLeft)
#macro	GAME_KEY_UP						keyboard_check(global.settings.gameKeyUp)
#macro	GAME_KEY_DOWN					keyboard_check(global.settings.gameKeyDown)
#macro	GAME_KEY_INTERACT				keyboard_check(global.settings.gameKeyInteract)
#macro	GAME_KEY_SPRINT					keyboard_check(global.settings.gameKeySprint)
#macro	GAME_KEY_READY_WEAPON			keyboard_check(global.settings.gameKeyReadyWeapon)
#macro	GAME_KEY_FLASHLIGHT				keyboard_check(global.settings.gameKeyFlashlight)
#macro	GAME_KEY_USE_WEAPON				keyboard_check(global.settings.gameKeyUseWeapon)

// These macros are similar to above, but they are for checking gamepad inputs instead of the keyboard.
#macro	GAME_PAD_RIGHT					gamepad_button_check(global.gamepadID, global.settings.gamePadRight)
#macro	GAME_PAD_LEFT					gamepad_button_check(global.gamepadID, global.settings.gamePadLeft)
#macro	GAME_PAD_UP						gamepad_button_check(global.gamepadID, global.settings.gamePadUp)
#macro	GAME_PAD_DOWN					gamepad_button_check(global.gamepadID, global.settings.gamePadDown)
#macro	GAME_PAD_INTERACT				gamepad_button_check(global.gamepadID, global.settings.gamePadInteract)
#macro	GAME_PAD_SPRINT					gamepad_button_check(global.gamepadID, global.settings.gamePadSprint)
#macro	GAME_PAD_READY_WEAPON			gamepad_button_check(global.gamepadID, global.settings.gamePadReadyWeapon)
#macro	GAME_PAD_FLASHLIGHT				gamepad_button_check(global.gamepadID, global.settings.gamePadFlashlight)
#macro	GAME_PAD_USE_WEAPON				gamepad_button_check(global.gamepadID, global.settings.gamePadUseWeapon)

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
	
	// --- Audio Settings --- //
	masterVolume		: 1.0,
	sndFxVolume			: 0.9,
	musicVolume			: 0.7,
	
	// --- Input Settings (Keyboard) --- //
	gameKeyRight		: vk_right,
	gameKeyLeft			: vk_left,
	gameKeyUp			: vk_up,
	gameKeyDown			: vk_down,
	gameKeyInteract		: vk_z,
	gameKeySprint		: vk_shift,
	gameKeyReadyWeapon	: vk_space,
	gameKeyFlashlight	: vk_f,
	gameKeyUseWeapon	: vk_z,
	
	// --- Input Settings (Gamepad) --- //
	gamePadRight		: gp_padr,
	gamePadLeft			: gp_padl,
	gamePadUp			: gp_padu,
	gamePadDown			: gp_padd,
	gamePadInteract		: gp_face1,
	gamePadSprint		: gp_shoulderl,
	gamePadReadyWeapon	: gp_shoulderr,
	gamePadFlashlight	: gp_face4,
	gamePadUseWeapon	: gp_face1,
	
	// --- Other Gamepad Settings --- //
	stickDeadzone		: 0.15,
	triggerThreshold	: 0.5,
};

// Stores the device ID for the gamepad that is currently connected to the game so its input can be polled.
global.gamepadID		= -1;

// Globals that store important information about the lighting system. The top variable is the management list
// for all light struct instances, and the other values store the surface ID and texture ID for the surface
// the lights are rendered onto, respectively.
global.lights			= ds_list_create();
global.lightSurface		= -1;
global.lightTexture		= -1;

// Uniforms for the lighting shader that will allow the properties of the shader to be changed on-the-fly as
// required for the current area in the game.
uLightColor				= shader_get_uniform(shd_lighting, "color");
uLightBrightness		= shader_get_uniform(shd_lighting, "brightness");
uLightSaturation		= shader_get_uniform(shd_lighting, "saturation");
uLightContrast			= shader_get_uniform(shd_lighting, "contrast");
uLightTexture			= shader_get_sampler_index(shd_lighting, "lightTex");

// Upon initialization, it stores the value -1, but will contain a map of structs that contain all the info
// about every item that can be collected within the game. This data is loaded in when a save file is loaded
// or a new playthrough is started.
global.itemData = -1;

// Upon initialization, it stores the value -1, but will contain an array of items the player current has on
// their person during gameplay; with the starting and maximum sizes being determined by the difficulty the
// user selected when starting a new playthrough.
global.inventory = -1;

#endregion Game Manager Global and Local Variable Initializations

// These calls are for testing purposes
load_item_data("items.dat");
inventory_initialize(GAME_FLAG_CMBTDIFF_STANDARD);