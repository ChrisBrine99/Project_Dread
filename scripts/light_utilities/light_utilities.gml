// Globals that store important information about the lighting system. The top variable is the management list
// for all light struct instances, and the other values store the surface ID and texture ID for the surface
// the lights are rendered onto, respectively.
global.lights			= ds_list_create();
global.lightSurface		= -1;
global.lightTexture		= -1;

/// @description 
///	Attempts to create a light source instance and add it to the list of currently active light sources. If 
/// the function provided in the parameter is not a valid light source struct, the function will return the
/// value "noone" (-4) to signify a light wasn't created.
///	
///	@param {Function}	lightFunc	The struct to be created as a new light source.
function light_create(_lightFunc){
	var _type = ds_map_find_value(global.structType, _lightFunc);
	if (_type != STRUCT_TYPE_LIGHT_SOURCE)
		return noone;
	
	var _light = instance_create_struct(_lightFunc);
	ds_list_add(global.lights, _light);
	return _light;
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