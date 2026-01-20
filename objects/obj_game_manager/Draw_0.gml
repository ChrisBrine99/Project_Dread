// Render entity shadows so long as the surface exists. Otherwise, shadows will be skipped for the frame and
// their surface will be recreated/redrawn in the next frame's pre-draw event.
if (surface_exists(global.shadowSurface)){
	var _xView = 0;
	var _yView = 0;
	with(CAMERA){
		_xView = xViewport;
		_yView = yViewport;
	}
	
	draw_set_alpha(0.5);
	draw_surface(global.shadowSurface, _xView, _yView);
	draw_set_alpha(1.0);
}

// Renders all Entities after they've been sorted by their y positions; the Entity's with smaller y positions 
// (Higher on the screen due to GameMaker's coordinate system) being drawn first.
var _delta	= global.deltaTime;
var _length = ds_grid_height(global.sortOrder);
for (var i = 0; i < _length; i++){
	with(global.sortOrder[# 0, i]){
		// Use the standard drawn event if the Entity doesn't override it OR they do but haven't been assigned
		// a proper function to use as the override.
		if (!ENTT_OVERRIDES_DRAW_EVENT || drawFunction == 0){
			entity_draw_event(_delta);
			continue;
		}
		script_execute(drawFunction, _delta);
	}
}