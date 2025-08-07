// Create a few local variables that will be used and referenced throughout the event by different instances
// and structures to avoid having to constantly get the same values over and over again.
var _minAlpha		= gpu_get_alphatestref() / 255.0;
var _viewX			= 0;
var _viewY			= 0;

// Scope into the camera struct in order to reference the viewport dimensions which are used for setting the
// size of the surface that all light sources will be drawn onto.
with(CAMERA){
	// Store the viewport's current x and y values once so each light can reference it without having to 
	// constantly grab it from the camera again and again on a light-by-light basis.
	_viewX	= viewportX;
	_viewY	= viewportY;
	
	// Exit from updating the current lighting if the game is completely paused. The surface will still be
	// drawn below, but no updates are made to it until the game is unpaused once more. 
	if (GAME_IS_PAUSED)
		break;
	
	// Since the lighting system is the first post-processing effect to be drawn, the world surface is checked
	// for a potential flushing by the GPU here and a new surface is created if that happens to be the case.
	// Then, the unaltered application surface is drawn to it.
	if (!surface_exists(global.worldSurface))
		global.worldSurface = surface_create(viewportWidth, viewportHeight);
	surface_set_target(global.worldSurface);
	draw_surface(application_surface, 0, 0);
	surface_reset_target();
	
	// Make sure the GPU hasn't flushed the lighting surface before handling any lighting code. If so, a new
	// surface will be created, and a reference to its texture ID will be stored so the lighting shader can 
	// utilize it.
	if (!surface_exists(global.lightSurface)){
		global.lightSurface = surface_create(viewportWidth, viewportHeight);
		global.lightTexture	= surface_get_texture(global.lightSurface);
	}
		
	// Begin drawing the on-screen light sources to a separate surface. The lights will then "punch holes" into
	// this surface through an additive blending mode as they are drawn.
	surface_set_target(global.lightSurface);
	draw_clear(c_black); // Clear the surface to be completely empty.
	gpu_set_blendmode(bm_add);
	
	// Loop through all existing light sources and render them if they are on screen.
	var _delta	= global.deltaTime;
	var _viewW	= viewportX + viewportWidth;
	var _viewH	= viewportY + viewportHeight;
	var _light	= noone;
	var _length	= ds_list_size(global.lights);
	var _index	= 0;
	while (_index < _length){
		_light = ds_list_find_value(global.lights, _index);
		with(_light){
			// Skip rendering the light source if it isn't currently active, the strength value is too low, or
			// the position/radius of the light is outside of the viewport's current bounds.
			if (!LGHT_IS_ACTIVE || strength <= _minAlpha || x + radius < _viewX || y + radius < _viewY 
					|| x - radius > _viewW || y - radius > _viewH)
				continue;
			draw_event(_viewX, _viewY, _delta);
			
			if (LGHT_IS_DESTROYED){ // Remove lights that are destroyed.
				ds_list_delete(global.lights, _index);
				_length--;	// Decrement the length value since an element was removed.
				continue;
			}
		}
		_index++;
	}
	
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1.0);
	surface_reset_target();
}

// Activate the main shader responsible for applying a given world lighting onto the application surface 
// (Stored in a separate surface "global.worldSurface") as well as blending that newly lit surface with the 
// lighting surface that was created in the block of code above.
shader_set(shd_lighting);
shader_set_uniform_f_array(uLightColor, [0.05, 0.05, 0.05]);
shader_set_uniform_f(uLightBrightness, -0.55);
shader_set_uniform_f(uLightSaturation,	0.26);
shader_set_uniform_f(uLightContrast,	0.19);
texture_set_stage(uLightTexture,		global.lightTexture);
draw_surface(global.worldSurface, _viewX, _viewY);
shader_reset();