#region Light Struct Global Variable Declaraitions

// Globals that store important information about the lighting system. The top variable is the management list for all light struct instances, 
// and the other values store the surface ID and texture ID for the surface the lights are rendered onto, respectively.
global.lights			= ds_list_create();
global.lightSurface		= -1;
global.lightTexture		= -1;

#endregion Light Struct Global Variable Declaraitions

#region Light Struct Creation/Destruction Functions

/// @description 
///	Attempts to create a new struct instance that is considered a light source. If the provided struct (One that is declared with the keyword
/// *constructor*) isn't found in the *global.structType* map or its index isn't that of a light source, no new instance will be created.
/// @returns 	{Real}
///	@param 		{Function}	lightFunc	The struct to be created as a new light source.
function light_create(_lightFunc){
	var _type = global.structType[? _lightFunc];
	if (is_undefined(_type) || _type != STRUCT_TYPE_LIGHT_SOURCE)
		return -1; // Don't even attempt creation if the provided struct isn't a valid light source struct function.

	ds_list_add(global.lights, instance_create_struct(_lightFunc));
	return ds_list_size(global.lights) - 1;
}

/// @description
///	Destroys a given light instance through the reference passed into the function's single parameter. It will remove their reference from the 
/// global light management list before finally removing it from the struct management list.
/// @param {Struct._structFunc}	lightRef	Reference to the str_light_source instance that will be deleted.
function light_destroy(_lightRef){
	var _index = ds_list_find_index(global.lights, _lightRef);
	if (_index == -1) // Function was called on a struct reference that isn't a light source; exit without deleting.
		return;
		
	ds_list_delete(global.lights, _index);
	instance_destroy_struct(_lightRef);
}

#endregion Light Struct Creation/Destruction Functions

#region Light Instance Retrieval Functions

/// @description 
///	Wrapper function for getting the instance of a light source, but treated as if it was a basic light source (*str_light_basic*).
/// @returns 	{Struct.str_light_basic}
/// @param		{Real}	index	The position the light instance occupies within *global.lights*.
function light_get_basic(_index){
	if (_index < 0 || _index >= ds_list_size(global.lights))
		return undefined;
	return ds_list_find_value(global.lights, _index);
}

/// @description 
///	Wrapper function for getting the instance of a light source, but treated as if it was a flickering light source (*str_light_flicker*).
/// @returns 	{Struct.str_light_flicker}
/// @param		{Real}						index	The position the light instance occupies within *global.lights*.
function light_get_flicker(_index){
	if (_index < 0 || _index >= ds_list_size(global.lights))
		return undefined;
	return ds_list_find_value(global.lights, _index);
}

/// @description 
///	Wrapper function for getting the instance of a light source, but treated as if it was a blinking light source (*str_light_blink*).
/// @returns 	{Struct.str_light_blink}
/// @param		{Real}	index	The position the light instance occupies within *global.lights*.
function light_get_blink(_index){
	if (_index < 0 || _index >= ds_list_size(global.lights))
		return undefined;
	return ds_list_find_value(global.lights, _index);
}

#endregion Light Instance Retrieval Functions