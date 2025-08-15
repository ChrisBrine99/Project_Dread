// Calculate and store the minimum possible alpha threshold so anything with an alpha value below this will be
// ignored during the rendering process.
var _minAlpha = gpu_get_alphatestref() / 255.0;

// 
with(PLAYER){
	with(interactableID){
		if (!INTR_CAN_PLAYER_INTERACT)
			break;
		draw_gui_event();
	}
}

// Loop through all currently active menus; rendering them to the screen if they're flagged to be visible and
// their current alpha level is above the minimum alpha threshold. If a menu fails to meet these conditions it
// will not be rendered to the GUI layer.
var _length = ds_list_size(global.menus);
for (var i = 0; i < _length; i++){
	with(global.menus[| i]){
		if (alpha <= _minAlpha || !MENU_IS_VISIBLE)
			continue;
		draw_gui_event(floor(x), floor(y));
	}
}

// Attempt to render the textbox onto the screen, but only if the alpha isn't below the minimum threshold and
// if its current y coordinate has it visible on the screen. Otherwise, it will not be rendered.
with(TEXTBOX){
	if (alpha <= _minAlpha || y >= VIEWPORT_HEIGHT)
		break;
	draw_gui_event();
}

draw_set_font(fnt_small);

draw_set_halign(fa_right);
draw_text_shadow(90, 5, 
	string("\n{0}\n{1}\n\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}", 
		floor(fps_real), 
		global.deltaTime, 
		GAME_IS_IN_GAME,
		GAME_IS_MENU_OPEN,
		GAME_IS_CUTSCENE_ACTIVE,
		GAME_IS_PAUSED,
		GAME_IS_ROOM_WARP_OCCURRING,
		GAME_IS_TRANSITION_ACTIVE,
		GAME_IS_TEXTBOX_OPEN,
		GAME_IS_GAMEPAD_ACTIVE,
	), 
	COLOR_DARK_RED
);

draw_set_halign(fa_left);
draw_text_shadow(5, 5, string("-- Frame Data --\ncurFPS\nDelta\n-- Global Flags --\ninGame\ninMenu\ninCutscene\nisPaused\nroomWarp\ntransitionActive\ntextboxOpen\ngamepadActive"), COLOR_WHITE);