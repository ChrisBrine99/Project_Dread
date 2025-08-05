// Renders a noise texture across the entire screen that will randomly shift about in a 64 x 64 pixel area to
// simulate how old CRT static would look or how old film grain would appear.
var _noiseTexWidth	= sprite_get_width(spr_noise) - 1;	// Offset width by 1 to adjust range to 0-63.
var _noiseTexHeight = sprite_get_height(spr_noise) - 1;	// Apply same offset for the height.
var _noiseScale		= 1.0;
var _noiseAlpha		= 0.15;
draw_sprite_tiled_ext(spr_noise, 0, irandom_range(0, _noiseTexWidth), irandom_range(0, _noiseTexHeight), 
	_noiseScale, _noiseScale, COLOR_TRUE_WHITE, _noiseAlpha);