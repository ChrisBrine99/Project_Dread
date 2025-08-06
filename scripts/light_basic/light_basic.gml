#region Macros for Basic Light Struct

// Values for the bits being utilized within a light struct's "flags" variable to enable/disable functionality
// during its lifetime.
#macro	LGHT_FLAG_LIMITED_LIFE			0x00000001
#macro	LGHT_FLAG_DESTROYED				0x40000000

// Checks to see whether a given flag within a light struct's "flags" variable is set to a 0 (false) or 1 (true).
#macro	LGHT_HAS_LIMITED_LIFE			((flags & LGHT_FLAG_LIMITED_LIFE)	!= 0)
#macro	LGHT_IS_DESTROYED				((flags & LGHT_FLAG_DESTROYED)		!= 0)

// Two macros that denote the minimum and maximum possible strength values for a light source, respectively.
#macro	LGHT_MIN_STRENGTH				0.0
#macro	LGHT_MAX_STRENGTH				1.0

#endregion Macros for Basic Light Struct

#region Basic Light Struct Definition

/// @param {Function}	index	The value of "str_light_source" as determined by GameMaker during runtime.
function str_light_basic(_index) : str_base(_index) constructor {
	x				= 0;
	y				= 0;
	radius			= 0.0;
	lifetime		= 0.0;
	color			= COLOR_BLACK;
	
	strength		= LGHT_MIN_STRENGTH;
	strengthFalloff = 0.0;
	
	///	@description 
	///	Called for every frame that the light source exists. Is responsible for rendering the light source with
	/// its given color and properties at its current position within the room.
	///	
	/// @param {Real}	viewX		Offset along the x axis caused by the viewport moving around the room.
	///	@param {Real}	viewY		Offset along the y axis caused by the viewport moving around the room.
	///	@param {Real}	delta		The difference in time between the execution of this frame and the last.
	draw_event = function(_viewX, _viewY, _delta) {
		if (LGHT_HAS_LIMITED_LIFE){
			lifetime -= _delta;
			if (lifetime <= 0.0){ // Prevent rendering and flag the light for destruction.
				flags |= LGHT_FLAG_DESTROYED;
				return;
			}
		}
		
		draw_set_alpha(strength);
		draw_circle_color(x - _viewX, y - _viewY, radius, color, COLOR_BLACK, false);
	}
	
	/// @description 
	///	Sets the base properties of the light source. Children of this basic light source struct can override
	///	this function to enabled setting up the parameters they add for their type of lighting style.
	///	
	/// @param {Real}	radius		Area from the origin of the light source that is illuminated by it.
	/// @param {Real}	color		The hue of the light source.
	/// @param {Real}	strength	How bright the light source appears in the world (Alpha under a different name).
	light_set_properties = function(_radius, _color, _strength){
		radius		= _radius;
		color		= _color;
		strength	= clamp(_strength, LGHT_MIN_STRENGTH, LGHT_MAX_STRENGTH);
	}
	
	/// @description 
	///	Sets the position within the room for the light's origin to be. Any floating-point values passed in
	///	as argument parameters will be truncated to become whole-pixel values.
	///	
	///	@param {Real}	x	Horizontal position of the light within the room.
	/// @param {Real}	y	Vertical position of the light within the room.
	static light_set_position = function(_x, _y){
		x = floor(_x);
		y = floor(_y);
	}
}

#endregion Basic Light Struct Definition

#region Global Functions for A Basic Light

/// @description 
///	Creates a basic light source instance. It has a set size, color, and strength that can be updated as needed,
/// but will never be updated automatically by the light itself.
///	
///	@param {Real}	x			Horizontal position of the light within the room.
/// @param {Real}	y			Vertical position of the light within the room.
/// @param {Real}	radius		Area from the origin of the light source that is illuminated by it.
/// @param {Real}	color		(Optional) The hue of the light source.
///	@param {Real}	strength	(Optional) How bright the light source appears in the world (Alpha under a different name).
/// @param {Real}	lifetime	(Optional) Determines how long the light is alive for relative to its creation.
/// @param {Bool}	flags		(Optional) Determines which substate bits to toggle on for the light.
function light_basic_create(_x, _y, _radius, _color = COLOR_TRUE_WHITE, _strength = LGHT_MAX_STRENGTH, _lifetime = 0.0, _flags = 0){
	var _light = light_create(str_light_basic);
	with(_light){ // Position the light and apply its sizing/color/strength.
		light_set_position(_x, _y);
		light_set_properties(_radius, _color, _strength);
		lifetime	= _lifetime;
		flags		= _flags;
	}
	return _light;
}

#endregion Global Functions for A Basic Light