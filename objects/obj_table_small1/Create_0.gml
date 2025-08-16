// Inherit the parent's create event, toggle the entity to be visible and active, and adjust other parameters as
// required for this object.
event_inherited();
flags			= ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE;
interactY		= y - 2;
interactMessage = "Inspect";