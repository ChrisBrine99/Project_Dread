// Renders a noise texture across the entire screen that will randomly shift about in a 64 x 64 pixel area to
// simulate how old CRT static would look or how old film grain would appear.
var _noiseScale		= 1.0;
var _noiseAlpha		= 0.15;
draw_sprite_tiled_ext(spr_noise, 0, xNoiseOffset, yNoiseOffset, _noiseScale, _noiseScale, COLOR_TRUE_WHITE, _noiseAlpha);

// Only updates the offset of the noise sprite that is tiled across the screen so long as the game isn't paused.
if (!GAME_IS_PAUSED){
	xNoiseOffset = irandom_range(0, sprite_get_width(spr_noise) - 1);	// Offset width by 1 to adjust range to 0-63.
	yNoiseOffset = irandom_range(0, sprite_get_height(spr_noise) - 1);	// Use similar logic for the height as well.
}

/// DEBUG INFORMATION DRAWN BELOW HERE //////////////////////////////////////////////////////////////////////

draw_set_font(fnt_small);
if (GAME_IS_MENU_OPEN || GAME_IS_TEXTBOX_OPEN){
	draw_text_shadow(5, 3, string("FPS {0}", floor(fps_real)), COLOR_TRUE_WHITE);
	return; // Only the FPS is displayed whenever a GUI element is active.
}

draw_set_halign(fa_right);

with(PLAYER){
	draw_text_shadow(315, 13, "--- Timers ---");
	for (var i = 0; i < PLYR_TOTAL_TIMERS; i++)
		draw_text_shadow(315, 23 + (i * 10), string("{0}: {1}", i, timers[i]));
		
	draw_text_shadow(315, 83, string(curAccuracyPenalty));
		
	with(equipment){
		if (weapon == INV_EMPTY_SLOT)
			break;
		
		draw_text_shadow(315, 3, 
			string("{0} (Count: {1})", 
			global.itemIDs[weaponStatRef.ammoTypes[curAmmoIndex]].itemName,
			ammoCount[curAmmoIndex])
		);
	}
}

draw_text_shadow(
	90, 3, 
	string(
		@"
		{0}
		{1}
		
		{2}
		{3}
		{4}
		{5}
		{6}
		{7}
		{8}
		{9}
		
		{10}
		{11}
		{12}
		
		{13}", 
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
draw_text_shadow(
	5, 3, 
	string(
		@"-- Frame Data --
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
		active"
	), 
	COLOR_TRUE_WHITE
);
