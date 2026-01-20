#region Cutscene Collider-Specific Flag Macros

// The list of flag bits being utilized by the cutscene collider currently.Each macro is their respective
// position within the variable (Ex. 0x80000000 is the 32nd bit, 0x00400000 is the 23rd bit, and so on).
#macro	CUTCOL_FLAG_DESTROY_ON_COLLIDE	0x00000001
#macro	CUTCOL_FLAG_EVENT_FLAG_STATE	0x00000002
#macro	CUTCOL_FLAG_NEVER_DESTROY		0x80000000

// Defines to check if each respective flag is currently set (1) or cleared (0).
#macro	CUTCOL_DESTROY_ON_COLLIDE		((flags & CUTCOL_FLAG_DESTROY_ON_COLLIDE)	!= 0)
#macro	CUTCOL_EVENT_FLAG_STATE			((flags & CUTCOL_FLAG_EVENT_FLAG_STATE)		!= 0)
#macro	CUTCOL_NEVER_DESTROY			((flags & CUTCOL_FLAG_NEVER_DESTROY)		!= 0)

#endregion Cutscene Collider-Specific Flag Macros

#region Variable Initialization

// The variable that stores the flags that are currently set of cleared by a cutscene collider instance.
flags		= 0;

// The bit within the event flag buffer that a given cutscene collider instance is tied to. Normally, this flag being
// the state this object is looking for will result in it being destroyed so the scene cannot replay, but if
// the NEVER_DESTROY flag is set, the cutscene will be replayable.
flagID		= EVENT_ID_INVALID;

// A list containing the actions that will be executed upon activating the cutscene through the player object
// colliding with this trigger object.
actionQueue = ds_list_create();

#endregion Variable Initialization