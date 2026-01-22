// Create a few local variables that will be used and referenced throughout the event by different instances
// and structures to avoid having to constantly get the same values over and over again.
var _minAlpha	= gpu_get_alphatestref() / 255.0;
var _delta		= global.deltaTime;
var _xView		= 0;
var _yView		= 0;
var _wView		= 0;
var _hView		= 0;
var _wTexel		= 0;
var _hTexel		= 0;

// Scope into the camera struct in order to reference the viewport dimensions which are used for setting the
// size of the surface that all light sources will be drawn onto.
with(CAMERA){
	// Store the viewport's current x/y, width/height, and texel size values once so each light can reference 
	// it without having to constantly grab it from the camera again and again on an per-object/struct basis.
	_xView	= xViewport;
	_yView	= yViewport;
	_wView	= wViewport;
	_hView	= hViewport;
	_wTexel	= wTexel;
	_hTexel	= hTexel;
	
	// Exit from updating the current lighting if the game is completely paused. The surface will still be
	// drawn below, but no updates are made to it until the game is unpaused once more. 
	if (GAME_IS_PAUSED)
		break;
	
	// Since the lighting system is the first post-processing effect to be drawn, the world surface is checked
	// for a potential flushing by the GPU here and a new surface is created if that happens to be the case.
	// Then, the unaltered application surface is drawn to it.
	if (!surface_exists(global.worldSurface))
		global.worldSurface = surface_create(wViewport, hViewport);
	surface_set_target(global.worldSurface);
	draw_surface(application_surface, 0, 0);
	surface_reset_target();
	
	// Make sure the GPU hasn't flushed the lighting surface before handling any lighting code. If so, a new
	// surface will be created, and a reference to its texture ID will be stored so the lighting shader can 
	// utilize it.
	if (!surface_exists(global.lightSurface)){
		global.lightSurface = surface_create(wViewport, hViewport);
		global.lightTexture	= surface_get_texture(global.lightSurface);
	}
		
	// Begin drawing the on-screen light sources to a separate surface. The lights will then "punch holes" into
	// this surface through an additive blending mode as they are drawn.
	surface_set_target(global.lightSurface);
	draw_clear(COLOR_BLACK);
	gpu_set_blendmode(bm_add);
	
	// Loop through all existing light sources and render them if they are on screen.
	var _length	= ds_list_size(global.lights);
	var _light	= noone;
	var _wViewX	= _xView + _wView;
	var _hViewY = _yView + _hView;
	var _index	= 0;
	while (_index < _length){
		_light = ds_list_find_value(global.lights, _index);
		with(_light){
			// Skip rendering the light source if it isn't currently active, the strength value is too low, or
			// the position/radius of the light is outside of the viewport's current bounds.
			if (!LGHT_IS_ACTIVE || strength <= _minAlpha || x + radius < _xView || y + radius < _yView 
					|| x - radius > _wViewX || y - radius > _hViewY)
				continue;
			draw_event(_xView, _yView, _delta);
			
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
draw_surface(global.worldSurface, _xView, _yView);
shader_reset();

// 
if (curBlurSigma > 0.0){
	shader_set(shd_screen_blur);
	shader_set_uniform_f(uTexelSize, _wTexel, _hTexel);
	shader_set_uniform_f(uBlurSteps, 3.0);
	shader_set_uniform_f(uSigma, curBlurSigma);

	// 
	shader_set_uniform_f(uBlurDirection, 1.0, 0.0);
	surface_set_target(global.worldSurface);
	draw_surface(application_surface, 0, 0);
	surface_reset_target();

	// 
	shader_set_uniform_f(uBlurDirection, 0.0, 1.0);
	draw_surface(global.worldSurface, _xView, _yView);
	shader_reset();
}

#region Debug Element Rendering Code

var _length = ds_list_size(debugLines);
if (_length > 0){
	var _debugLines = debugLines;
	draw_set_color(COLOR_WHITE);
	for (var i = 0; i < _length; i++){
		with(debugLines[| i]){
			draw_set_alpha(1.0 * curLifetime / lifetime);
			draw_line(xStart, yStart, xEnd, yEnd);
		
			curLifetime -= _delta;
			if (curLifetime <= 0.0){
				delete _debugLines[| i];
				ds_list_delete(_debugLines, i);
				_length--;
				i--;
			}
		}
	}
}

#endregion Debug Element Rendering Code

// Display the interaction prompt for the current interactable the player is focused on. If that interactable
// objects happens to not be active/visible or the player cannot currently interact with it, the prompt will
// not be displayed on the UI.
with(PLAYER){
	with(interactableID){
		if (!ENTT_IS_VISIBLE || !INTR_CAN_PLAYER_INTERACT)
			break;
		draw_gui_event(_xView, _yView);
	}
}

// Loop through all currently active menus; rendering them to the screen if they're flagged to be visible and
// their current alpha level is above the minimum alpha threshold. If a menu fails to meet these conditions it
// will not be rendered to the GUI layer.
_length = ds_list_size(global.menus);
for (var i = 0; i < _length; i++){
	with(global.menus[| i]){
		if (alpha <= _minAlpha || !MENU_IS_VISIBLE)
			continue;
		draw_gui_event(x + _xView, y + _yView);
	}
}

// Attempt to render the textbox onto the screen, but only if the alpha isn't below the minimum threshold and
// if its current y coordinate has it visible on the screen. Otherwise, it will not be rendered.
with(TEXTBOX){
	if (alpha <= _minAlpha || y >= VIEWPORT_HEIGHT)
		break;
	draw_gui_event(_xView, _yView, _delta);
}

// 
with(TEXTBOX_LOG){
	if (alpha <= _minAlpha)
		break;
	draw_gui_event(_xView, _yView, _delta);
}

// Draw the screen fade onto the screen after all UI elements have been rendered onto the application surface.
with(SCREEN_FADE){
	if (!FADE_IS_ACTIVE || alpha < _minAlpha)
		break; // Skip over rendering the screen fade it its alpha isn't high enough or it is inactive.
	
	draw_sprite_ext(spr_rectangle, 0, _xView, _yView, _wView, _hView, 0.0, color, alpha);
}