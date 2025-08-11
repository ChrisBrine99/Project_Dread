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