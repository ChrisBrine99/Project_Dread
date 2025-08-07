#region Flickering Light Macro Definitions

// Determines the minimum possible amounts for the amount of time between a flicker update and minimum amount
// to adjust the radius by during said update, respectively.
#macro	LGHT_MIN_FLICKER_TIME			0.05
#macro	LGHT_MIN_FLICKER_AMOUNT			0.5

#endregion Flickering Light Macro Definitions

#region Flickering Light Struct Definition

/// @param {Function}	index	The value of "str_light_flicker" as determined by GameMaker during runtime.
function str_light_flicker(_index) : str_light_basic(_index) constructor {
	// The smallest and largest possible sizes the light can flicker within.
	minRadius			= 0.0;
	maxRadius			= 0.0;
	
	// Variables responsible for the flicker effect's overall speed. The first variables determine the minimum 
	// and maximum amount of time between a flicker adjustment, and the last is responsible for tracking if
	// the required duration of time has passed in order to update said flickering.
	minFlickerInterval	= 0.0;
	maxFlickerInterval	= 0.0;
	flickerTimer		= 0.0;
	
	// Stores the starting strength of the light since it will be altered and its grows and shrinks within the
	// light's set range of flickering.
	baseStrength		= 0.0;
	
	/// Store the original draw event's reference so the code for handling the light's lifetime (If it has one)
	/// doesn't need to be copy and pasted into this overridden draw event.
	__draw_event = draw_event;
	///	@description 
	///	Called for every frame that the light source exists. It'ss responsible for rendering the light source 
	/// with its given color and properties at its current position within the room. Also handles the light 
	/// flicker logic since there is no step event.
	///	
	/// @param {Real}	viewX		Offset along the x axis caused by the viewport moving around the room.
	///	@param {Real}	viewY		Offset along the y axis caused by the viewport moving around the room.
	///	@param {Real}	delta		The difference in time between the execution of this frame and the last.
	draw_event = function(_viewX, _viewY, _delta){
		flickerTimer -= _delta;
		if (flickerTimer <= 0.0){ // Update the light to "flicker" to a new size.
			flickerTimer	= max(LGHT_MIN_FLICKER_TIME, // Minimum amount of time is 1/60th of a second.
								random_range(minFlickerInterval, maxFlickerInterval));
			
			var _prevRadius = radius; // Store so the difference can be checked.
			radius			= random_range(minRadius, maxRadius);
			
			// Ensure the flicker was large enough to actually be seen within the game.
			var _difference = _prevRadius - radius;
			if (abs(_difference) < LGHT_MIN_FLICKER_AMOUNT){
				radius		= _prevRadius + (LGHT_MIN_FLICKER_AMOUNT * sign(_difference));
				_difference	= LGHT_MIN_FLICKER_AMOUNT; // Overwrite the value that was too small.
			}
			
			// Dynamically update the strength relative to its base value and the difference in radius after the flicker.
			strength = baseStrength + (baseStrength * (_difference / radius * sign(_difference)));
		}
		
		__draw_event(_viewX, _viewY, _delta);
	}
	
	/// @description 
	///	Sets all possible properties for the light source with a single function call.
	///	
	/// @param {Real}	minRadius			The minimum possible distance the light source can illuminate.
	///	@param {Real}	maxRadius			The maximum possible distance the light source can illuminate.
	/// @param {Real}	minFlickerInterval	Smallest possible duration between size shifts for the light source's flicker effect.
	/// @param {Real}	maxFlickerInterval	Largest possible duration between size shifts for the light source's flicker effect.
	/// @param {Real}	color				The hue of the light source.
	/// @param {Real}	strength			How bright the light source appears in the world (Alpha under a different name).
	light_set_properties = function(_minRadius, _maxRadius, _minFlickerInterval, _maxFlickerInterval, _color, _strength){
		radius				= _maxRadius;			// Set the maximum possible radius by default.
		minRadius			= _minRadius;
		maxRadius			= _maxRadius;
		minFlickerInterval	= _minFlickerInterval;
		maxFlickerInterval	= _maxFlickerInterval;
		flickerTimer		= _maxFlickerInterval;	// Set the maximum possible duration by default.
		color				= _color;
		strength			= clamp(_strength, LGHT_MIN_STRENGTH, LGHT_MAX_STRENGTH);
		baseStrength		= strength;
	}
}

#endregion Flickering Light Struct Definition

#region Global Functions for A Flickering Light

/// @description 
///	Creates a light source instance that will flicker randomly while it is active. The flickering effect is
/// automatically handled by the instance itself, and the characteristics of that flicker can be adjusted as
/// needed by changing the effect's parameters.
///	
///	@param {Real}	x					Horizontal position of the light within the room.
/// @param {Real}	y					Vertical position of the light within the room.
/// @param {Real}	minRadius			Minimum possible area the light can illuminate.
/// @param {Real}	maxRadius			Maximum possible area the light can illuminate.
/// @param {Real}	minFlickerInterval	Smallest possible duration between size shifts for the light source's flicker effect.
///	@param {Real}	maxFlickerInterval	Largest possible duration between size shifts for the light source's flicker effect.
/// @param {Real}	color				(Optional) The hue of the light source.
///	@param {Real}	strength			(Optional) How bright the light source appears in the world (Alpha under a different name).
/// @param {Real}	lifetime			(Optional) Determines how long the light is alive for relative to its creation.
/// @param {Bool}	flags				(Optional) Determines which substate bits to toggle on for the light.
function light_flicker_create(_x, _y, _minRadius, _maxRadius, _minFlickerInterval, _maxFlickerInterval, _color = COLOR_TRUE_WHITE, _strength = LGHT_MAX_STRENGTH, _lifetime = 0.0, _flags = LGHT_FLAG_ACTIVE){
	var _light = light_create(str_light_flicker);
	with(_light){ // Position the light and apply its sizing/color/strength and flicking parameters.
		light_set_position(_x, _y);
		light_set_properties(
			_minRadius,				_maxRadius, 
			_minFlickerInterval,	_maxFlickerInterval, 
			_color, 
			_strength
		);
		lifetime	= _lifetime;
		flags		= _flags;
	}
	return _light;
}

#endregion Global Functions for A Flickering Light