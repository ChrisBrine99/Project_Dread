if (GAME_IS_PAUSED)
	return; // Prevent anything from updating while the game is considered paused.

// Ensures that objects will be automatically destroyed if their destroyed flag is toggled and they aren't set to
// be invincible. Otherwise, they will remain active despite the flag to signal their destruction being set.
with(par_dynamic_entity){
	if (ENTT_IS_DESTROYED) { instance_destroy_object(id); }
}