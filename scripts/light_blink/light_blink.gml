#region Blinking Light Macro Definitions

// Determines the minimum interval of time between a light blinking between on and off.
#macro	LGHT_MIN_BLINK_TIME				0.05

#endregion Blinking Light Macro Definitions

#region Blinking Light Struct Definition

/// @param {Function}	index	The value of "str_light_blink" as determined by GameMaker during runtime.
function str_light_blink(_index) : str_light_basic(_index) constructor {
	// These determine the range of time that will elapse between the light blinking to on or off. The third
	// variable is simply what stores the timer as it decrements form whatever value it was set to after a blink
	// occurs (This value is anything within the min and max ranges).
	minBlinkInterval	= 0.0;
	maxBlinkInterval	= 0.0;
	blinkTimer			= 0.0;
	
	/// Store the original draw event's reference so the code for handling the light's lifetime (If it has one)
	/// doesn't need to be copy and pasted into this overridden draw event.
	__draw_event = draw_event;
	/// @description
	///	Called for every frame that the light source exists. It's responsible for rendering the light source 
	/// with its given color and properties at its current position within the room. On top of that, it manages 
	/// the blinking logic that will toggle the light on and off at random intervals.
	///	
	/// @param {Real}	viewX		Offset along the x axis caused by the viewport moving around the room.
	///	@param {Real}	viewY		Offset along the y axis caused by the viewport moving around the room.
	///	@param {Real}	delta		The difference in time between the execution of this frame and the last.
	draw_event = function(_viewX, _viewY, _delta){
		blinkTimer -= _delta;
		if (blinkTimer <= 0.0){
			blinkTimer = max(LGHT_MIN_FLICKER_TIME, // Minimum amount of time is 1/60th of a second.
							random_range(minBlinkInterval, maxBlinkInterval));
			
			// Toggle the flag bit to enable/disable the rendering of the light, but not the logic that is 
			// also in this draw event that handles the blinking timer.
			if (LGHT_IS_ACTIVE) { flags &= ~LGHT_FLAG_ACTIVE; }
			else				{ flags |=  LGHT_FLAG_ACTIVE; }
		}
		
		// Only call the base function if the light is set to active.
		if (LGHT_IS_ACTIVE) { __draw_event(_viewX, _viewY, _delta); }
	}
	
	/// @description 
	///	Sets all possible properties for the light source with a single function call.
	///
	/// @param {Real}	radius				Area from the origin of the light source that is illuminated by it.
	/// @param {Real}	minBlinkInterval	Minimum amount of time for a blink to occur for the light.
	/// @param {Real}	maxBlinkInterval	Maximum amount of time for a blink to occur for the light.
	/// @param {Real}	color				The hue of the light source.
	/// @param {Real}	strength			How bright the light source appears in the world (Alpha under a different name).
	light_set_properties = function(_radius, _minBlinkInterval, _maxBlinkInterval, _color, _strength){
		radius				= _radius;
		color				= _color;
		minBlinkInterval	= _minBlinkInterval;
		maxBlinkInterval	= _maxBlinkInterval;
		blinkTimer			= _maxBlinkInterval; // Set the maximum possible duration by default.
		strength			= clamp(_strength, LGHT_MIN_STRENGTH, LGHT_MAX_STRENGTH);
	}
}

#endregion Blinking Light Struct Definition

#region Global Functions for A Blinking Light

/// @description
///	Creates a light source that will blink on and off at a given interval between the minimum and maximum
/// ranges specified through the arguments in this function. This blinking effect is automatically handled
/// by the instance of the light itself.
///	
///	@param {Real}	x					Horizontal position of the light within the room.
/// @param {Real}	y					Vertical position of the light within the room.
/// @param {Real}	radius				Area from the origin of the light source that is illuminated by it.
/// @param {Real}	minBlinkInterval	Minimum amount of time for a blink to occur for the light.
/// @param {Real}	maxBlinkInterval	Maximum amount of time for a blink to occur for the light.
/// @param {Real}	color				(Optional) The hue of the light source.
///	@param {Real}	strength			(Optional) How bright the light source appears in the world (Alpha under a different name).
/// @param {Real}	lifetime			(Optional) Determines how long the light is alive for relative to its creation.
/// @param {Bool}	flags				(Optional) Determines which substate bits to toggle on for the light.
function light_blink_create(_x, _y, _radius, _minBlinkInterval, _maxBlinkInterval, _color = COLOR_TRUE_WHITE, _strength = LGHT_MAX_STRENGTH, _lifetime = 0.0, _flags = 0){
	var _light = light_create(str_light_blink);
	with(_light){
		light_set_position(_x, _y);
		light_set_properties(
			_radius,
			_minBlinkInterval, _maxBlinkInterval,
			_color,
			_strength
		);
		lifetime	= _lifetime;
		flags		= _flags;
	}
	return _light;
}

#endregion Global Functions for A Blinking Light