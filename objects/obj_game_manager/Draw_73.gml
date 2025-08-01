// 
var _scale			= global.settings.windowScale;
var _viewX			= 0;
var _viewY			= 0;

// Scope into the camera struct in order to reference the viewport dimensions which are used for setting the
// size of the surface that all light sources will be drawn onto.
with(CAMERA){
	// 
	_viewX	= viewportX;
	_viewY	= viewportY;
	
	// 
	if (!surface_exists(global.worldSurface))
		global.worldSurface = surface_create(viewportWidth, viewportHeight);
	surface_set_target(global.worldSurface);
	draw_surface(application_surface, 0, 0);
	surface_reset_target();
	
	// 
	if (!surface_exists(global.lightSurface)){
		global.lightSurface = surface_create(viewportWidth, viewportHeight);
		global.lightTexture	= surface_get_texture(global.lightSurface);
	}
		
	// 
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
			if (x + radius < _viewX || y + radius < _viewY || x - radius > _viewW || y - radius > _viewH)
				continue; // Skip over all off-screen light sources.
			draw_event(_viewX, _viewY, _delta);
			
			if (LGHT_IS_DESTROYED){ // Remove lights that are destroyed.
				ds_list_delete(global.lights, _index);
				continue; // Skips over increment to account for removed element from list.
			}
		}
		_index++;
	}
	
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1.0);
	surface_reset_target();
}

// 
shader_set(shd_lighting);
shader_set_uniform_f_array(uLightColor, [0.05, 0.05, 0.05]);
shader_set_uniform_f(uLightBrightness, -0.55);
shader_set_uniform_f(uLightSaturation,	0.26);
shader_set_uniform_f(uLightContrast,	0.19);
texture_set_stage(uLightTexture,		global.lightTexture);
draw_surface(global.worldSurface, _viewX, _viewY);
shader_reset();