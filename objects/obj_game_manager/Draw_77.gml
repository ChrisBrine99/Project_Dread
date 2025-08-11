var _scale = global.settings.windowScale;

shader_set(shd_retro_effects);

// Set the properties of the three major effects this shader handles, and the constant dither matrix for the PS1-
// style dithering effect that can be optionally enabled by the player is they choose (They're active on first
// launch of the game).
shader_set_uniform_f(uScanlineFactor,		0.55);
shader_set_uniform_f(uQuantizeLevel,		31.0);
shader_set_uniform_f(uWindowScale,			_scale);
shader_set_uniform_f_array(uDitherMatrix, [
	-4.0,  0.0, -3.0,  1.0,
	 2.0, -2.0,  3.0, -1.0,
	-3.0,  1.0, -4.0,  0.0,
	 3.0, -1.0,  2.0, -2.0
]);

// Transfer over each flag that the shader will use to determine if each of the three effects are currently set
// to active by the player. They are passed in as integers since GameMaker doesn't have a "uniform_b" variant for
// setting shader uniforms and this happens to work.
shader_set_uniform_i(uQuantizationActive,	STNG_IS_QUANTIZATION_ON);
shader_set_uniform_i(uDitheringActive,		STNG_IS_DITHERING_ON);
shader_set_uniform_i(uScanlinesActive,		STNG_ARE_SCANLINES_ON);

draw_surface_ext(application_surface, 0, 0, _scale, _scale, 0.0, COLOR_TRUE_WHITE, 1.0);
shader_reset();