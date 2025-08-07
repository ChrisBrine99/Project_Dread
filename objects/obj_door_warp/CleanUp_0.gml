// Call the parent event to cleanup anything that needed tidying up from the properites inherited from the parent
// objects and its parent(s).
event_inherited();

// Loop through and remove all structs for each lock that exists for the door. The list is then destroyed so it
// can be removed from memory.
var _length = ds_list_size(lockData);
for (var i = 0; i < _length; i++)
	delete lockData[| i];
ds_list_destroy(lockData);