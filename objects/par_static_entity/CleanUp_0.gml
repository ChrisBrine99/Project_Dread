// Clear the light source from memory if it happens to be occupied for the Entity in question.
if (lightSource) { light_destroy(lightSource); }

// Removes index from sorting grid to account for the now-removed entity.
// var _height = ds_grid_height(global.sortOrder);
// ds_grid_resize(global.sortOrder, 2, _height - 1);