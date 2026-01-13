// Count how many static and dynamic entities are current in the room so they all have their y positions stored
// in the grid that will determine the order that they are rendered onto the screen.
var _count = instance_number(par_dynamic_entity) + instance_number(par_static_entity);
ds_grid_resize(global.sortOrder, 2, _count);

// Grab the camera's viewport position and size so it can be used to cull all off-screen entities. The width
// and height values are offset by the x and y position of the viewport so it doesn't need to be done on a
// per-entity basis.
var _viewX = 0;
var _viewY = 0;
var _viewW = 0;
var _viewH = 0;
with(CAMERA){
	_viewX = viewportX;
	_viewY = viewportY;
	_viewW = _viewX + viewportWidth;
	_viewH = _viewY + viewportHeight;
}

// Since all entities are looped through in this event, it makes sense to drawn their shadows here as well
// if they have one to draw. So, the surface is created if the GPU has flushed it, that surface becomes the
// render target, and the surface is completely cleared to a value of zero.
if (!surface_exists(global.shadowSurface))
	global.shadowSurface = surface_create(VIEWPORT_WIDTH, VIEWPORT_HEIGHT);
surface_set_target(global.shadowSurface);
draw_clear_alpha(COLOR_BLACK, 0.0);
draw_set_color(COLOR_BLACK); // All shadows are drawn completely black at full opacity.

// Loop through all dynamic entities and add them to the rendering ds_grid (global.sortOrder) if they should
// be drawn onto the screen. Entities that are found to be off-screen will not be drawn, and entities with
// shadows will have their shadow drawn onto the shadow surface.
var _index = 0;
with(par_dynamic_entity){
	if (!ENTT_IS_VISIBLE || x < _viewX - sprite_width || x > _viewW + sprite_width ||
			y < _viewY - sprite_height || y > _viewH + sprite_height)
		continue;
	
	// Add the required data from the entity to the sorting order grid, and increment _index to move onto
	// the next entity in this with loop.
	global.sortOrder[# 0, _index] = id;
	global.sortOrder[# 1, _index] = y;
	_index++;
	
	// Finally, if the dynamic entity has a shadow, it will be drawn below this check. If there isn't a 
	// shadow to display, the loop will simply move onto the next dynamic entity and skip the code below.
	if (!ENTT_HAS_SHADOW || shadowFunction == 0)
		continue;
	script_execute(shadowFunction, x + shadowX - _viewX, y + shadowY - _viewY);
}
numDynamicDrawn = _index;

// After all active and visible dynamic entities have been added to the rendering ds_grid, all static entities
// will be looped through to check if they're active and on-screen.
with(par_static_entity){
	if (!ENTT_IS_VISIBLE || x < _viewX - sprite_width || x > _viewW + sprite_width ||
			y < _viewY - sprite_height || y > _viewH + sprite_height)
		continue;
	
	// Much like above, the required details for the entity are copied over into the sorting grid and the
	// value for _index is incremented to move onto the next available slot in said grid.
	global.sortOrder[# 0, _index] = id;
	global.sortOrder[# 1, _index] = y;
	_index++;
	
	// Finally, a static entity will perform the same check to see if a shadow should be drawn for the entity
	// in question like is done above for dynamic entities. The loop skips the code if it doesn't have one.
	if (!ENTT_HAS_SHADOW || shadowFunction == 0)
		continue;
	script_execute(shadowFunction, x + shadowX - _viewX, y + shadowY - _viewY);
}
numStaticDrawn = _index - numDynamicDrawn;

// If required, use the room's wall tiles to mask any shadows that would normally overlap them. This avoids
// issues where a shadow pokes through the top of a ceiling tile onto the wall below it.
if (maskLayerID != -1){
	gpu_set_blendmode_ext(bm_zero, bm_zero);
	draw_tilemap(maskLayerID, -_viewX, -_viewY);
	gpu_set_blendmode(bm_normal);
}
surface_reset_target();

// Finally, check if the number of entities to be rendered is less than the total count of them in the current
// room. If so, resize to match the number of rendered entities and then sort from lowest to highest y value.
if (_index < _count) { ds_grid_resize(global.sortOrder, 2, _index); }
ds_grid_sort(global.sortOrder, 1, true);