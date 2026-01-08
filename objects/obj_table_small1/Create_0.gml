// Inherit the parent's create event and toggle the entity to be visible and active.
event_inherited();
flags			= ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE;

// Add a shadow for the underside of the table so light doesn't completely illuminate the visible portion of
// what is underneath it.
entity_add_shadow(
	entity_draw_shadow_square, 
	-8, -2,		// Offsets compared to x and y of object.
	16, 10		// Size along the x and y axes.
);

// Adjust some of the parameters used during the interact process.
interactY		= y - 2;
interactMessage = "Inspect";