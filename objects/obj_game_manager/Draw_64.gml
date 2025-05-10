draw_set_font(fnt_small);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_text(5, 5, string("FPS\nDelta\nFlags"));

draw_set_color(c_maroon);
draw_set_halign(fa_right);
draw_text(60, 5, string("{0}\n{1}\n{2}", floor(fps_real), global.deltaTime, global.flags));