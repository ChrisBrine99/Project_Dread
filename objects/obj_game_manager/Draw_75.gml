// Renders a noise texture across the entire screen that will randomly shift about in a 64 x 64 pixel area to
// simulate how old CRT static would look or how old film grain would appear.
var _noiseTexWidth	= sprite_get_width(spr_noise) - 1;	// Offset width by 1 to adjust range to 0-63.
var _noiseTexHeight = sprite_get_height(spr_noise) - 1;	// Apply same offset for the height.
var _noiseScale		= 1.0;
var _noiseAlpha		= 0.15;
draw_sprite_tiled_ext(spr_noise, 0, irandom_range(0, _noiseTexWidth), irandom_range(0, _noiseTexHeight), 
	_noiseScale, _noiseScale, COLOR_TRUE_WHITE, _noiseAlpha);
	
// After the noise texture is rendered, the screen fade will be drawn if it is active and past the threshold of
// discarding for the GPU relative to the fade effect's current alpha value.
with(SCREEN_FADE){
	if (!FADE_IS_ACTIVE || alpha < gpu_get_alphatestref() / 255.0)
		return;
	
	var _color = fadeColor;
	var _alpha = alpha;
	with(CAMERA){ // Jump into the camera's scope so the viewport's dimensions can be utilized.
		draw_sprite_ext(spr_rectangle, 0, 0, 0, viewportWidth, viewportHeight, 0, _color, _alpha);
	}
}