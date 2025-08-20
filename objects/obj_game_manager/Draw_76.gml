// Count how many static and dynamic entities are current in the room so they all have their y positions stored
// in the grid that will determine the order that they are rendered onto the screen.
var _count = instance_number(par_dynamic_entity) + instance_number(par_static_entity);
ds_grid_resize(global.sortOrder, 2, _count);

// Loop through each of these dynamic and static entities; grabbing their ID for reference when drawing and their
// y positions for sorting said ID values.
var _index = 0;
with(par_dynamic_entity){
	global.sortOrder[# 0, _index] = id;
	global.sortOrder[# 1, _index] = y;
	_index++;
}
with(par_static_entity){
	global.sortOrder[# 0, _index] = id;
	global.sortOrder[# 1, _index] = y;
	_index++;
}
ds_grid_sort(global.sortOrder, 1, true); // Sort by lowest y to highest y values.