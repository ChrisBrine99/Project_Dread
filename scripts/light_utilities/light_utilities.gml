#region Global Variables Related to the Lighting System

// Globals that store important information about the lighting system. The top variable is the management list
// for all light struct instances, and the other values store the surface ID and texture ID for the surface
// the lights are rendered onto, respectively.
global.lights			= ds_list_create();
global.lightSurface		= -1;
global.lightTexture		= -1;

#endregion Global Variables Related to the Lighting System

#region General Creation/Destruction Functions for Light Sources

/// @description 
///	
///	
///	@param {Function}	structFunc	The light source struct to instantiate.
function light_create(_structFunc){
	
}

/// @description
///	Destroys a given light instance through the reference passed into the function's single parameter. It will
/// remove their reference from the global light management list before finally removing it from the struct
///	management list.
///	
/// @param {Struct._structRef}	lightRef	Reference to the str_light_source instance that will be deleted.
function light_destroy(_lightRef){
	var _index = ds_list_find_index(global.lights, _lightRef);
	if (_index == -1) // Function was called on a struct reference that isn't a light source; exit without deleting.
		return;
	ds_list_delete(global.lights, _index);
	instance_destroy_struct(_lightRef);
}

#endregion General Creation/Destruction Functions for Light Sources