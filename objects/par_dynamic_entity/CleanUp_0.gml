// Clear the light source from memory if it happens to be occupied for the Entity in question.
if (lightSource) { light_destroy(lightSource); }

// Removes index from sorting grid to account for the now-removed entity.
// ds_grid_resize(global.sortOrder, 2, ds_grid_height(global.sortOrder) - 1);