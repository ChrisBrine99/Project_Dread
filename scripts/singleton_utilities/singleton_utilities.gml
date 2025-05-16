// Macros for the unique key values supplied to each special struct/object instance.
#macro	KEY_GAME_MANAGER				"GameManager"
#macro	KEY_CAMERA						"Camera"
#macro	KEY_TEXTBOX						"Textbox"
#macro	KEY_PLAYER						"Player"

// Macros to simply the typing required to reference a given special struct/object instance.
#macro	GAME_MANAGER					global.sInstances[? KEY_GAME_MANAGER]
#macro	CAMERA							global.sInstances[? KEY_CAMERA]
#macro	TEXTBOX							global.sInstances[? KEY_TEXTBOX]
#macro	PLAYER							global.sInstances[? KEY_PLAYER]

// The map that manages the instance IDs and references to all existing special objects within the game. These
// objects are "special" in that only one instance may exist of any of them during runtime, and attempts to create
// multiples instances of them will fail when utilizing the proper creation functions. They also cannot be deleted
// during runtime and attempts to do so will also fail when utilizing the proper deletion functions.
global.sInstances = ds_map_create();