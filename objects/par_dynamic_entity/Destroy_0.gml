// Clear the light source from memory if it happens to be occupied for the Entity in question.
if (!is_undefined(lightSource))
	light_destroy(lightSource);