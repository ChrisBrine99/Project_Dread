// A pair of variables that stores the posiiton of the flag (Starting count from 0) that is tied to this cutscene,
// and the state that flag needs to be in for this collider to be able to execute the cutscene data it contains.
flagID		= EVENT_ID_INVALID;
flagState	= true;

// 
actionQueue = ds_list_create();