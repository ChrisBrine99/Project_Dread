// Activate the shader responsible for the PSX-like effects that get applied onto everything currently on
// the screen (The noise is drawn on top of all of this in the Draw GUI event).
shader_set(shd_retro_effects);

// Apply the values that will enable the scanline, quantization, and dithering effects to function.
shader_set_uniform_f(uScanlineFactor,		0.55);
shader_set_uniform_f(uQuantizeLevel,		31.0);
shader_set_uniform_f_array(uDitherMatrix, [
	-4.0,  0.0, -3.0,  1.0,
	 2.0, -2.0,  3.0, -1.0,
	-3.0,  1.0, -4.0,  0.0,
	 3.0, -1.0,  2.0, -2.0
]);

// Get the size of the application surface which is equal to the viewport's current dimensions. This is used to
// apply the dither effect across the pixels of the output image.
var _uViewportSize = uViewportSize;
with(CAMERA) { shader_set_uniform_f(_uViewportSize, wViewport, hViewport); }

// Transfer over each flag that the shader will use to determine if each of the three effects are currently set
// to active by the player. They are passed in as integers since GameMaker doesn't have a "uniform_b" variant for
// setting shader uniforms and this happens to work.
shader_set_uniform_i(uQuantizationActive,	STNG_IS_QUANTIZATION_ON);
shader_set_uniform_i(uDitheringActive,		STNG_IS_DITHERING_ON);
shader_set_uniform_i(uScanlinesActive,		STNG_ARE_SCANLINES_ON);

var _scale = global.settings.windowScale;
draw_surface_ext(application_surface, 0, 0, _scale, _scale, 0.0, COLOR_TRUE_WHITE, 1.0);
shader_reset();