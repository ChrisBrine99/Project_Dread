// Adjust some default variables so the Game Maker animation system can be overridden by a custom implementation.
image_speed		= 0.0;
image_index		= 0;
visible			= false;

#region Variable Initializations

// A value storing bits that enable/disable various aspects of the Entity's general functionality.
flags			= 0;

// Stores the currently executing state, as well as the last state to be executed AND the state to shift to at the
// end of the current frame if applicable (Its value matches that of "curState" otherwise).
curState		= 0;
nextState		= 0;
lastState		= 0;

// If required, the entity may utilize its own drawing function to replace the standard one. Having this set
// to 0 will cause the entity to fallback to said standard drawing function.
drawFunction	= 0;

// Variables for the entity's custom animation implementation, which will utilize the sprite's speed set within
// the editor as well as a target animation frame rate of 60 fps to provide a frame-independent animation system.
animSpeed		= 0.0;
animFps			= 0.0;
animLength		= 0;
animLoopStart	= 0;

// 
shadowFunction	= 0;
shadowX			= 0;
shadowY			= 0;
shadowWidth		= 0;
shadowHeight	= 0;

// Stores a reference to a light source struct that will be placed at a given offset relative to the Entity's
// current position. The offset on the x and y axes are stored in the two other values below.
lightSource		= noone;
lightX			= 0;
lightY			= 0;

#endregion Variable Initializations