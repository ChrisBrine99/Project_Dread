// Renders a noise texture across the entire screen that will randomly shift about in a 64 x 64 pixel area to
// simulate how old CRT static would look or how old film grain would appear.
var _noiseScale		= 1.0;
var _noiseAlpha		= 0.15;
draw_sprite_tiled_ext(spr_noise, 0, noiseOffsetX, noiseOffsetY, _noiseScale, _noiseScale, COLOR_TRUE_WHITE, _noiseAlpha);

// Only updates the offset of the noise sprite that is tiled across the screen so long as the game isn't paused.
if (!GAME_IS_PAUSED){
	noiseOffsetX = irandom_range(0, sprite_get_width(spr_noise) - 1);	// Offset width by 1 to adjust range to 0-63.
	noiseOffsetY = irandom_range(0, sprite_get_height(spr_noise) - 1);	// Use similar logic for the height as well.
}

/// DEBUG INFORMATION DRAWN BELOW HERE //////////////////////////////////////////////////////////////////////

draw_set_font(fnt_small);
draw_set_halign(fa_right);

draw_text_shadow(90, 5, 
	string("\n{0}\n{1}\n\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}\n\n{10}\n{11}\n{12}\n\n{13}", 
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
		numDynamicDrawn + numStaticDrawn,
		numDynamicDrawn,
		numStaticDrawn,
		ds_list_size(global.structs),
	), 
	COLOR_DARK_RED
);

draw_set_halign(fa_left);
draw_text_shadow(5, 5, 
	string(@"-- Frame Data --
	curFPS
	Delta
	-- Global Flags --
	inGame
	inMenu
	inCutscene
	isPaused
	roomWarp
	transitionActive
	textboxOpen
	gamepadActive
	-- Render Data --
	drawnEntities
	drawnDynamic
	drawnStatic
	-- Struct Data --
	curActiveStructs"), COLOR_WHITE);
