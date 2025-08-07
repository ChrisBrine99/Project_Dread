/*with(SCREEN_FADE){
	activate_screen_fade(0.1, 0.01, COLOR_DARK_GRAY);
}*/

if (GAME_IS_PAUSED){
	global.flags &= ~GAME_FLAG_PAUSED;
} else{
	global.flags |= GAME_FLAG_PAUSED;
}