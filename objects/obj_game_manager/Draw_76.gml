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

// Loop through all dynamic and all static entities to see if they are going to be rendered or not. The code
// for the dynamic entity with loop is duplicated for the static entity with loop since it's faster than
// putting it into a function that is called twice.
var _index = 0;
with(par_dynamic_entity){
	// If the entity isn't active to begin with; they won't be rendered regardless of their position in the
	// room relative to the viewport, so the loop immediately moves onto the next entity.
	if (!ENTT_IS_ACTIVE)
		continue;
	
	// Check if the entity's current position and sprite are out of the bounds of the screen. If so, they will
	// be flagged as invisible, and be ignored in the render loop.
	if (x < _viewX + sprite_width || x > _viewW - sprite_width || 
			y < _viewY + sprite_height || y > _viewH - sprite_height){
		flags = flags & ~ENTT_FLAG_VISIBLE;
		continue;
	}
	flags = flags | ENTT_FLAG_VISIBLE;
	
	// Store the ID of the current entity in the first column as well as its y position into the grid's second 
	// column. Then, _index is incremented so the next row will be used for the next entity.
	global.sortOrder[# 0, _index] = id;
	global.sortOrder[# 1, _index] = y;
	_index++;
}
with(par_static_entity){
	// If the entity isn't active to begin with; they won't be rendered regardless of their position in the
	// room relative to the viewport, so the loop immediately moves onto the next entity.
	if (!ENTT_IS_ACTIVE)
		continue;
	
	// Check if the entity's current position and sprite are out of the bounds of the screen. If so, they will
	// be flagged as invisible, and be ignored in the render loop.
	if (x < _viewX - sprite_width || x > _viewW + sprite_width || 
			y < _viewY - sprite_height || y > _viewH + sprite_height){
		flags = flags & ~ENTT_FLAG_VISIBLE;
		continue;
	}
	flags = flags | ENTT_FLAG_VISIBLE;
	
	// Store the ID of the current entity in the first column as well as its y position into the grid's second 
	// column. Then, _index is incremented so the next row will be used for the next entity.
	global.sortOrder[# 0, _index] = id;
	global.sortOrder[# 1, _index] = y;
	_index++;
}

// Finally, check if the number of entities to be rendered is less than the total count of them in the current
// room. If so, resize to match the number of rendered entities and then sort from lowest to highest y value.
if (_index < _count) { ds_grid_resize(global.sortOrder, 2, _index); }
ds_grid_sort(global.sortOrder, 1, true);