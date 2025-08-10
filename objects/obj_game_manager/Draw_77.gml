var _scale = global.settings.windowScale;

shader_set(shd_retro_effects);
shader_set_uniform_f(uScanlineIntensity,	0.65);
shader_set_uniform_f(uQuantizeLevel,		31.0);
draw_surface_ext(application_surface, 0, 0, _scale, _scale, 0.0, COLOR_TRUE_WHITE, 1.0);
shader_reset();