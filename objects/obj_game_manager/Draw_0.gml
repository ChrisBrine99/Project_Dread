// Renders all Entities after they've been sorted by their y positions; the Entity's with smaller y positions 
// (Higher on the screen due to GameMaker's coordinate system) being drawn first.
var _delta	= global.deltaTime;
var _length = ds_grid_height(global.sortOrder);
for (var i = 0; i < _length; i++){
	with(global.sortOrder[# 0, i]){
		if (!ENTT_IS_VISIBLE)
			continue; // Entity's that aren't currently visible will have their drawn event/function skipped.
		
		// Use the standard drawn event if the Entity doesn't override it OR they do but haven't been assigned
		// a proper function to use as the override.
		if (!ENTT_OVERRIDES_DRAW_EVENT || drawFunction == 0){
			entity_draw_event(_delta);
			continue;
		}
		script_execute(drawFunction, _delta);
	}
}

/*draw_set_alpha(0.75);
draw_set_color(COLOR_LIGHT_BLUE);
with(par_interactable){ draw_circle(interactX, interactY, interactRadius, false); }
*/