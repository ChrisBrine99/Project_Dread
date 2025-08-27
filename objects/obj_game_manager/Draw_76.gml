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

// Loop through all dynamic entities and add them to the rendering ds_grid (global.sortOrder) if they should
// be drawn onto the screen.
var _index = 0;
with(par_dynamic_entity){
	// Ensure the entity is currently considered visible (Also means they're considered active) while also 
	// being visible on the screen before adding them to the grid that is responsible for sorting them from 
	// top to bottom and rendering them.
	if (ENTT_IS_VISIBLE && x >= _viewX - sprite_width && x <= _viewW + sprite_width && 
			y >= _viewY - sprite_height && y <= _viewH + sprite_height){
		global.sortOrder[# 0, _index] = id;
		global.sortOrder[# 1, _index] = y;
		_index++;
	}
}
numDynamicDrawn = _index;

// After all active and visible dynamic entities have been added to the rendering ds_grid, all static entities
// will be looped through to check if they're active and on-screen.
with(par_static_entity){
	// Ensure the entity is currently considered visible (Also means they're considered active) while also 
	// being visible on the screen before adding them to the grid that is responsible for sorting them from 
	// top to bottom and rendering them.
	if (ENTT_IS_VISIBLE && x >= _viewX - sprite_width && x <= _viewW + sprite_width && 
			y >= _viewY - sprite_height && y <= _viewH + sprite_height){
		global.sortOrder[# 0, _index] = id;
		global.sortOrder[# 1, _index] = y;
		_index++;
	}
}
numStaticDrawn = _index - numDynamicDrawn;

// Finally, check if the number of entities to be rendered is less than the total count of them in the current
// room. If so, resize to match the number of rendered entities and then sort from lowest to highest y value.
if (_index < _count) { ds_grid_resize(global.sortOrder, 2, _index); }
ds_grid_sort(global.sortOrder, 1, true);