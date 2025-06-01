#region Light Source Struct Definition

/// @param {Function}	index	The value of "str_light_source" as determined by GameMaker during runtime.
function str_light_source(_index) : str_base(_index) constructor {
	x			= 0;
	y			= 0;
	radius		= 0.0;
	strength	= 0.0;
	color		= c_black;
	
	///	@description 
	///	Called for every frame that the light source exists. Is responsible for rendering the light source with
	/// its given color and properties at its current position within the room.
	///	
	/// @param {Real}	viewX		Offset along the x axis caused by the viewport moving around the room.
	///	@param {Real}	viewY		Offset along the y axis caused by the viewport moving around the room.
	///	@param {Real}	delta		The difference in time between the execution of this frame and the last.
	draw_event = function(_viewX, _viewY, _delta) {
		draw_set_alpha(strength);
		draw_circle_color(x - _viewX, y - _viewY, radius, color, c_black, false);
	}
	
	/// @description 
	///	Sets the position within the room for the light's origin to be. Any floating-point values passed in
	///	as argument parameters will be truncated to become whole-pixel values.
	///	
	///	@param {Real}	x	Horizontal position of the light within the room.
	/// @param {Real}	y	Vertical position of the light within the room.
	light_set_position = function(_x, _y){
		x = floor(_x);
		y = floor(_y);
	}
	
	/// @description 
	///	Sets the base properties of the light source. Children of this basic light source struct can override
	///	this function to enabled setting up the parameters they add for their type of lighting style.
	///	
	/// @param {Real}	radius		Area from the origin of the light source that is illuminated by it.
	/// @param {Real}	color		(Optional) The hue of the light source.
	/// @param {Real}	strength	(Optional) How bright the light source appears in the world (Alpha under a different name).
	light_set_properties = function(_radius, _color = c_white, _strength = 1.0){
		radius		= _radius;
		color		= _color;
		strength	= clamp(_strength, 0.0, 1.0);
	}
}

#endregion Light Source Struct Definition

#region Global Functions for Light Sources

/// @description 
///	Creates a light source at the given position within the current room. If an Entity is creating this light,
///	it will follow that Entity automatically. Otherwise, it will remain static within the room unless moved
///	manually through a cutscene or something similar.
///	
///	@param {Real}	x			Horizontal position of the light within the room.
/// @param {Real}	y			Vertical position of the light within the room.
/// @param {Real}	radius		Area from the origin of the light source that is illuminated by it.
/// @param {Real}	color		(Optional) The hue of the light source.
///	@param {Real}	strength	(Optional) How bright the light source appears in the world (Alpha under a different name).
/// @param {Bool}	persistent	(Optional) Determines if the light will remain existing between rooms.
function light_create(_x, _y, _radius, _color = c_white, _strength = 1.0, _persistent = false){
	var _light = instance_create_struct(str_light_source);
	with(_light){ // Position the light and apply its sizing/color/strength.
		light_set_position(_x, _y);
		light_set_properties(_radius, _color, _strength);
		if (_persistent) { flags |= STR_FLAG_PERSISTENT; }
	}
	
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

#endregion Global Functions for Light Sources