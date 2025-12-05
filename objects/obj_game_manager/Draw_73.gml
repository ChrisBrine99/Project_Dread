// Create a few local variables that will be used and referenced throughout the event by different instances
// and structures to avoid having to constantly get the same values over and over again.
var _minAlpha		= gpu_get_alphatestref() / 255.0;
var _delta			= global.deltaTime;
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
	var _length	= ds_list_size(global.lights);
	var _viewW	= viewportX + viewportWidth;
	var _viewH	= viewportY + viewportHeight;
	var _light	= noone;
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

#region Debug Element Rendering Code

var _length = ds_list_size(debugLines);
if (_length > 0){
	var _debugLines = debugLines;
	draw_set_color(COLOR_WHITE);
	for (var i = 0; i < _length; i++){
		with(debugLines[| i]){
			draw_set_alpha(1.0 * curLifetime / lifetime);
			draw_line(startX, startY, endX, endY);
		
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
		draw_gui_event(_viewX, _viewY);
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
		draw_gui_event(x + _viewX, y + _viewY);
	}
}

// Attempt to render the textbox onto the screen, but only if the alpha isn't below the minimum threshold and
// if its current y coordinate has it visible on the screen. Otherwise, it will not be rendered.
with(TEXTBOX){
	if (alpha <= _minAlpha || y >= VIEWPORT_HEIGHT)
		break;
	draw_gui_event(_viewX, _viewY, _delta);
}

// 
with(TEXTBOX_LOG){
	if (alpha <= _minAlpha)
		break;
	draw_gui_event(_viewX, _viewY, _delta);
}

// Draw the screen fade onto the screen after all UI elements have been rendered onto the application surface.
with(SCREEN_FADE){
	if (!FADE_IS_ACTIVE || alpha < gpu_get_alphatestref() / 255.0)
		break; // Skip over rendering the screen fade it its alpha isn't high enough or it is inactive.
	
	var _color = fadeColor;
	var _alpha = alpha;
	with(CAMERA){ // Jump into the camera's scope so the viewport's values can be utilized.
		draw_sprite_ext(spr_rectangle, 0, viewportX, viewportY, viewportWidth, viewportHeight, 0, _color, _alpha);
	}
}

// FOR TESTING PURPOSES ONLY
if (GAME_IS_MENU_OPEN){
	draw_set_font(fnt_small);
	draw_set_color(COLOR_TRUE_WHITE);
	draw_text(_viewX + 5, _viewY + 3, string("FPS {0}", floor(fps_real)));
}