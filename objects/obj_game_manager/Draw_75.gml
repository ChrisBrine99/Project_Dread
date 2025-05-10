// Renders a noise texture across the entire screen that will randomly shift about in a 64 x 64 pixel area to
// simulate how old CRT static would look or how old film grain would appear.
draw_sprite_tiled_ext(spr_noise, 0, irandom_range(0, 63), irandom_range(0, 63), 1.0, 1.0, c_white, 0.15);