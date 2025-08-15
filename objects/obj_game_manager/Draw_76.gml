// 
var _count = instance_number(par_dynamic_entity) + instance_number(par_static_entity);
ds_grid_resize(global.sortOrder, 2, _count);

// 
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