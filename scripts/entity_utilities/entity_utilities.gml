#region Shared Macros Between Entity Types

// Values for the flag bits found within an entity (Both dynamic and static utilize these) that will determine
// what non-function states apply to them currently. Each flag has its own unique purpose and effect.
#macro	ENTT_FLAG_SHADOW				0x01000000
#macro	ENTT_FLAG_PAUSE_FOR_CUTSCENE	0x02000000
#macro	ENTT_FLAG_OVERRIDE_DRAW			0x04000000
#macro	ENTT_FLAG_ANIMATION_END			0x08000000
#macro	ENTT_FLAG_VISIBLE				0x10000000
#macro	ENTT_FLAG_ACTIVE				0x20000000
#macro	ENTT_FLAG_DESTROYED				0x40000000
#macro	ENTT_FLAG_INVINCIBLE			0x80000000


// Macros for the code required to check the state of a given flag or flag(s) that are required for certain
// events or code to trigger within a given entity. They simple condense those checks down to a single term.
#macro	ENTT_HAS_SHADOW					((flags & ENTT_FLAG_SHADOW)				!= 0)
#macro	ENTT_PAUSES_FOR_CUTSCENE		((flags & ENTT_FLAG_PAUSE_FOR_CUTSCENE)	!= 0)
#macro	ENTT_OVERRIDES_DRAW_EVENT		((flags & ENTT_FLAG_OVERRIDE_DRAW)		!= 0)
#macro	ENTT_DID_ANIMATION_END			((flags & ENTT_FLAG_ANIMATION_END)		!= 0)
#macro	ENTT_IS_ACTIVE					((flags & ENTT_FLAG_ACTIVE				!= 0) && (flags & ENTT_FLAG_DESTROYED) == 0)
#macro	ENTT_IS_VISIBLE					((flags & (ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE))	== ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE)
#macro	ENTT_IS_DESTROYED				((flags & ENTT_FLAG_DESTROYED			!= 0) && (flags & ENTT_FLAG_INVINCIBLE)	== 0)

#endregion Shared Macros Between Entity Types

#region Shared Global Variables Entities Utilize

// 
global.pausedEntities = ds_list_create();

#endregion Shared Global Variables Entities Utilize

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
	
	flags			= flags & ~ENTT_FLAG_ANIMATION_END;
	image_index	   += animSpeed * _delta;
	if ((animSpeed > 0.0 && image_index >= animLength) || (animSpeed < 0.0 && image_index <= 0.0)){
		flags	    = flags | ENTT_FLAG_ANIMATION_END;
		image_index = animLoopStart;
	}
	draw_sprite_ext(sprite_index, floor(image_index), x, y, 
		image_xscale, image_yscale, image_angle, image_blend, image_alpha);
}

#endregion Shared Event Functions Between Entity Types

#region Shared Utility Functions Between Entity Types

/// @description 
///	
///	
///	@param {Id.Instance}	id	Instance ID for the entity that will be paused.
function entity_pause(_id){
	var _isPersistent	= false;
	var _curState		= STATE_NONE;
	var _nextState		= STATE_NONE;
	var _lastState		= STATE_NONE;
	with(_id){ // Copy the required values into the local variables.
		_isPersistent	= persistent;
		_curState		= curState;
		_nextState		= nextState;
		_lastState		= lastState;
		
		// Clear the state values so the Entity is now paused.
		curState		= STATE_NONE;
		nextState		= STATE_NONE;
		lastState		= STATE_NONE;
	}
	
	// Create the small struct that will store the state information for the paused entity until they can
	// be unpaused once again. Persistence is also stored so the data isn't removed during room transitions
	// if it represents the state of a persistent entity.
	ds_list_add(global.pausedEntities, {
		entityID		: _id, 
		isPersistent	: _isPersistent,
		curState		: _curState,
		nextState		: _nextState,
		lastState		: _lastState
	});
}

/// @description 
/// 
///	
///	@param {Id.Instance}	id	Instance ID for the entity that will be paused.
function entity_unpause(_id){
	var _size = ds_list_size(global.pausedEntities);
	if (_size == 0) // Exit instantly when there aren't any entities currently paused.
		return;
	
	// A slight optimization that ignores the binary search below should their only be a single entity that
	// is currently paused. If the ID matches, the list is emptied and the Entity returns to its state prior
	// to being paused.
	if (_size == 1){
		with(global.pausedEntities[| 0]){
			if (entityID == _id)
				return; // Entity did not match; exit the function.
				
			// Store the values to return to the Entity into local variables so they can be passed through
			// once jumping into the Entity's scope via their ID.
			var _curState	= curState;
			var _nextState	= nextState;
			var _lastState	= lastState;
			with(_id){
				curState	= _curState;
				nextState	= _nextState;
				lastState	= _lastState;
			}
		}
		return;
	}
	
	var _data	= noone;
	var _middle = _size >> 1;
	var _start	= 0;
	var _end	= _size - 1;
	while (_start != _end){
		_data = global.pausedEntities[| _start];
		if (_data.entityID > _id){
			_start	= _middle; // Cut off bottom half; search remainder of instances.
			_middle = (_end + _start) >> 1;
			// Fix for potential endless looping; ensures the next interation is the last.
			if (_start == _middle)
				_middle = _end;
			continue;
		}

		if (_data.entityID < _id){
			_end	= _middle; // Cut off top half; search remainder of instances.
			_middle = (_end + _start) >> 1;
			// Fix for potential endless looping; ensures the next interation is the last.
			if (_end == _middle)
				_middle = _start;
			continue;
		}
		
		// Matching Entity has been found, return them to their state prior to being paused by copying the
		// state data found in the data into local values that are then passed into the entity's state values.
		var _curState	= STATE_NONE;
		var _nextState	= STATE_NONE;
		var _lastState	= STATE_NONE;
		with(_data){
			_curState	= curState;
			_nextState	= nextState;
			_lastState	= lastState;
			
			// Jump into the entity in question via their ID to return their state values to them.
			with(_id){
				curState	= _curState;
				nextState	= _nextState;
				lastState	= _lastState;
			}
		}
		
		// Finally, delete the data from the paused entities list as said data is no longer required.
		var _index = ds_list_find_index(global.pausedEntities, _data);
		ds_list_delete(global.pausedEntities, _index);
		break;
	}
}

/// @description 
///	
///	
function entity_unpause_all(){
	var _curState	= STATE_NONE;
	var _nextState	= STATE_NONE;
	var _lastState	= STATE_NONE;
	var _length		= ds_list_size(global.pausedEntities);
	for (var i = 0; i < _length; i++){
		with(global.pausedEntities[| i]){
			_curState	= curState;
			_nextState	= nextState;
			_lastState	= lastState;
			with(entityID){ // Return the stored state values to the previously paused entity.
				curState	= _curState;
				nextState	= _nextState;
				lastState	= _lastState;
			}
		}
	}
	ds_list_clear(global.pausedEntities);
}

/// @description 
///	A general function for rendering an entity's shadow as a circle. Note that this circle's horizontal
/// radius is equal to the value found in "shadowWidth", and its vertical radius is the value found in
/// "shadowHeight".
///	
///	@param {Real}	x	The x position of the entity and its shadow's horizontal offset from said position.
/// @param {Real}	y	The y position of the entity and its shadow's vertical offset from said position.
function entity_draw_shadow_circle(_x, _y){
	draw_ellipse(_x - shadowWidth, _y - shadowHeight, _x + shadowWidth - 1, _y + shadowHeight - 1, false);
}

/// @description 
///	A general function for rendering an entity's shadow as a square or rectangle.
///	
///	@param {Real}	x	The x position of the entity and its shadow's horizontal offset from said position.
/// @param {Real}	y	The y position of the entity and its shadow's vertical offset from said position.
function entity_draw_shadow_square(_x, _y){
	draw_sprite_ext(spr_rectangle, 0, _x, _y, shadowWidth, shadowHeight, 0.0, COLOR_BLACK, 1.0);
}

#endregion Shared Utility Functions Between Entity Types

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
///	Adds a shadow to the entity while also allowing the way that shadow will drawn and its properties to be
/// set at the same time as the flag that enables shadow rendering to begin with.
///	
///	@param {Function}	function	Script or method to call when the shadow is being drawn.
/// @param {Real}		x			Offset of the shadow relative to the entity's x position.
/// @param {Real}		y			Offset of the shadow relative to the entity's y position.
/// @param {Real}		width		Size of the shadoe along the x axis.
/// @param {Real}		height		Size of the shadow along the y axis.
function entity_add_shadow(_function, _x, _y, _width, _height){
	if (ENTT_HAS_SHADOW || !script_exists(_function))
		return;
		
	flags			= flags | ENTT_FLAG_SHADOW;
	shadowFunction	= _function;
	shadowX			= _x;
	shadowY			= _y;
	shadowWidth		= _width;
	shadowHeight	= _height;
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
/// @param {Real}	flags		(Optional) Determines which substate bits to toggle on for the light.
function entity_add_basic_light(_x, _y, _radius, _color = COLOR_TRUE_WHITE, _strength = 1.0, _lifetime = 0.0, _flags = LGHT_FLAG_ACTIVE){
	// Don't attempt to create a light source if a reference already occupies the storage variable.
	if (lightSource)
		return;
	
	lightSource = light_basic_create(x + _x, y + _y, _radius, _color, _strength, _lifetime, _flags);
	lightX		= _x;
	lightY		= _y;
}

#endregion Shared Miscellaneous Functions Between Entity Types