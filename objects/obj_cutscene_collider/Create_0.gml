#region Cutscene Collider-Specific Flag Macros

// 
#macro	CUTCOL_FLAG_DESTROY_ON_COLLIDE	0x00000001
#macro	CUTCOL_DESTROY_ON_COLLIDE		((flags & CUTCOL_FLAG_DESTROY_ON_COLLIDE) != 0)

#endregion Cutscene Collider-Specific Flag Macros

#region Variable Initialization

// A pair of variables that stores the posiiton of the flag (Starting count from 0) that is tied to this cutscene,
// and the state that flag needs to be in for this collider to be able to execute the cutscene data it contains.
flagID		= EVENT_ID_INVALID;
flagState	= true;

// A list containing the actions that will be executed upon activating the cutscene through the player object
// colliding with this trigger object.
actionQueue = ds_list_create();

#endregion Variable Initialization