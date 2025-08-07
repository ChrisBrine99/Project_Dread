#region Shared Macros Between Entity Types

// Values for the flag bits found within an entity (Both dynamic and static utilize these) that will determine
// what non-function states apply to them currently. Each flag has its own unique purpose and effect.
#macro	ENTT_FLAG_SHADOW				0x02000000
#macro	ENTT_FLAG_OVERRIDE_DRAW			0x04000000
#macro	ENTT_FLAG_ANIMATION_END			0x08000000
#macro	ENTT_FLAG_VISIBLE				0x10000000
#macro	ENTT_FLAG_ACTIVE				0x20000000
#macro	ENTT_FLAG_DESTROYED				0x40000000
#macro	ENTT_FLAG_INVINCIBLE			0x80000000


// Macros for the code required to check the state of a given flag or flag(s) that are required for certain
// events or code to trigger within a given entity. They simple condense those checks down to a single term.
#macro	ENTT_HAS_SHADOW					((flags & ENTT_FLAG_SHADOW)				!= 0)
#macro	ENTT_OVERRIDES_DRAW_EVENT		((flags & ENTT_FLAG_OVERRIDE_DRAW)		!= 0)
#macro	ENTT_DID_ANIMATION_END			((flags & ENTT_FLAG_ANIMATION_END)		!= 0)
#macro	ENTT_IS_ACTIVE					((flags & ENTT_FLAG_ACTIVE)				!= 0 && (flags & ENTT_FLAG_DESTROYED)	== 0)
#macro	ENTT_IS_VISIBLE					((flags & ENTT_FLAG_VISIBLE)			!= 0 && (flags & ENTT_FLAG_ACTIVE)		!= 0)
#macro	ENTT_IS_DESTROYED				((flags & ENTT_FLAG_DESTROYED)			!= 0 && (flags & ENTT_FLAG_INVINCIBLE)	== 0)

#endregion Shared Macros Between Entity Types

#region Shared Event Functions Between Entity Types

/// @description
///	The default Entity drawing function, which will also handle animation that Entity should their current
/// sprite have more than one frame OR their animation speed is set to some non-zero value.
///	
/// @param {Real}	delta		The current delta time for the frame.
function entity_draw_event(_delta){
	if (animSpeed == 0.0){ // No animation logic currently required, simply draw the current frame for the sprite.
		draw_sprite_ext(sprite_index, floor(image_index), x, y, 
			image_xscale, image_yscale, image_angle, image_blend, image_alpha);
		return;
	}
	
	flags		   &= ~ENTT_FLAG_ANIMATION_END;
	image_index	   += animSpeed * _delta;
	if ((animSpeed > 0.0 && image_index >= animLength) || (animSpeed < 0.0 && image_index <= 0.0)){
		flags	   |= ENTT_FLAG_ANIMATION_END;
		image_index = animLoopStart;
	}
	draw_sprite_ext(sprite_index, floor(image_index), x, y, 
		image_xscale, image_yscale, image_angle, image_blend, image_alpha);
}

#endregion Shared Event Functions Between Entity Types

#region Shared Miscellaneous Functions Between Entity Types

/// @description 
///	Assigns a new sprite for the Entity to use. If the sprite resource already matches what the Entity's current
///	sprite is, the current animation speed can be updated as required through calling this function.
///	
/// @param {Asset.GMSprite}	sprite		Index for the sprite to assign to the Entity in question.
/// @param {Real}			speed		(Optional) Animation speed relative to the value set within the sprite editor.
/// @param {Real}			start		(Optional) Starting frame for the animation upon changing.
/// @param {Real}			loopStart	(Optional) Frame to start at once the sprite is required to loop.
function entity_set_sprite(_sprite, _speed = 1.0, _start = 0, _loopStart = 0){
	if (sprite_index != _sprite && sprite_exists(_sprite)){
		sprite_index	= _sprite;
		image_index		= _start;
		animLength		= sprite_get_number(_sprite);
		animFps			= sprite_get_speed(_sprite);
		animLoopStart	= clamp(_loopStart, 0, animLength - 1);
	}
	animSpeed = _speed;
}

/// @description 
///	Creates an instance of str_light_source and stores it within the Entity's lightSource variable. The x and
///	y parameters denote the offsets along each axis relative to the Entity's current position.
///	
///	@param {Real}	x			Offset relative to the entity's current x position.
/// @param {Real}	y			Offset relative to the entity's current y position.
/// @param {Real}	radius		Area from the origin of the light source that is illuminated by it.
/// @param {Real}	color		(Optional) The hue of the light source.
///	@param {Real}	strength	(Optional) How bright the light source appears in the world (Alpha under a different name).
/// @param {Real}	lifetime	(Optional) Determines how long the light is alive for relative to its creation.
/// @param {Bool}	flags		(Optional) Determines which substate bits to toggle on for the light.
function entity_add_basic_light(_x, _y, _radius, _color = COLOR_TRUE_WHITE, _strength = 1.0, _lifetime = 0.0, _flags = 0){
	// Don't attempt to create a light source if a reference already occupies the storage variable.
	if (lightSource)
		return;
	
	lightSource = light_basic_create(x + _x, y + _y, _radius, _color, _strength, _lifetime, _flags);
	lightX		= _x;
	lightY		= _y;
}

#endregion Shared Miscellaneous Functions Between Entity Types