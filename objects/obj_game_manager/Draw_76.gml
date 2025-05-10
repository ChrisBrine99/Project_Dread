var _length = ds_grid_height(global.sortOrder);
for (var i = 0; i < _length; i++) // Get depth values for each dynamic/static entity.
	global.sortOrder[# 1, i] = global.sortOrder[# 0, i].y;
ds_grid_sort(global.sortOrder, 1, true); // Sort by lowest y to highest y values.