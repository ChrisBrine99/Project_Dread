// Calculate and store the minimum possible alpha threshold so anything with an alpha value below this will be
// ignored during the rendering process.
var _minAlpha = gpu_get_alphatestref() / 255.0;

// Display the interaction prompt for the current interactable the player is focused on. If that interactable
// objects happens to not be active/visible or the player cannot currently interact with it, the prompt will
// not be displayed on the UI.
with(PLAYER){
	with(interactableID){
		if (!ENTT_IS_VISIBLE || !INTR_CAN_PLAYER_INTERACT)
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
		draw_gui_event(x, y);
	}
}

// Attempt to render the textbox onto the screen, but only if the alpha isn't below the minimum threshold and
// if its current y coordinate has it visible on the screen. Otherwise, it will not be rendered.
var _delta = global.deltaTime;
with(TEXTBOX){
	if (alpha <= _minAlpha || y >= VIEWPORT_HEIGHT)
		break;
	draw_gui_event(_delta);
}

// FOR TESTING PURPOSES ONLY
if (GAME_IS_MENU_OPEN){
	draw_set_font(fnt_small);
	draw_set_color(COLOR_TRUE_WHITE);
	draw_text(5, 3, string("FPS {0}", floor(fps_real)));
}