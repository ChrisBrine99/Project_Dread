var _scale = global.settings.windowScale;

shader_set(shd_scanlines); // Apply a scanline effect to the entire screen.
draw_surface_ext(application_surface, 0, 0, _scale, _scale, 0.0, c_white, 1.0);
shader_reset();