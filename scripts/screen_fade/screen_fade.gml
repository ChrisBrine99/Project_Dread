#region Macros for Screen Fade Struct

// Macros that represent flags that can be set or cleared to determine what the screen fade struct is able
// to process at a given moment in time.
#macro	FADE_FLAG_ACTIVE			0x00000001
#macro	FADE_FLAG_ALLOW_FADE_OUT	0x00000002

// Macros that contain the checks required to see if a flag is set or cleared within the "flags" variable
// of str_screen_fade.
#macro	FADE_IS_ACTIVE				((flags & FADE_FLAG_ACTIVE) != 0)
#macro	FADE_CAN_FADE_OUT			((flags & FADE_FLAG_ALLOW_FADE_OUT) != 0)

#endregion Macros for Screen Fade Struct

#region Screen Fade Struct Definition

/// @param {Function}	index	The value of "str_screen_fade" as determined by GameMaker during runtime.
function str_screen_fade(_index) : str_base(_index) constructor {
	flags			= STR_FLAG_PERSISTENT;
	
	// Like entities and certain other objects, these values will store the current state (This matches the
	// value of "nextState" if no change should occur), the next state which is a switch needs to occur, and
	// the previous state that was executed before the current one.
	curState		= 0;
	nextState		= 0;
	lastState		= 0;
	
	// Determines the characteristics of the fade for the current iteration of the effect; the speed of fading
	// the screen to the set color, and the speed of fading out from that set color.
	fadeInSpeed		= 0.0;
	fadeOutSpeed	= 0.0;
	fadeColor		= COLOR_BLACK;
	
	// Stores the current opacity of the screen fade. At 1.0, the screen will be completely filled with the
	// currently set color for the fade.
	alpha			= 0.0;
	
	/// @description 
	///	Activates the screen fade effect, which will transition the game's view from the room's viewport to a
	/// single color determined on a per-fade activation basis. One the fade has completed it will begin to
	/// return the game back to the room's viewport if the fade is set to automatically do so. Otherwise, it
	/// will wait until the flag to allow fading out is set by another place in the code.
	/// 
	///	@param {Real}	inSpeed			How fast the screen will fade completely into the desired color.
	/// @param {Real}	outSpeed		How fast the screen will fade from the desired color back to the current viewport contents.
	/// @param {Real}	color			Determines the color that will completely fill the screen once the fade is fully opaque.
	/// @param {Bool}	manualFadeOut	(Optional) When true, the screen will remain the fade color until the flag to allow a fade out is manually set elsewhere in the code.
	activate_screen_fade = function(_inSpeed, _outSpeed, _color, _manualFadeOut = false){
		// Don't apply new parameters to the screen fade if it or another transition is already active.
		if (FADE_IS_ACTIVE || GAME_IS_TRANSITION_ACTIVE)
			return;
		object_set_state(state_fade_in);
		flags		    = flags | FADE_FLAG_ACTIVE;
		
		// Apply the parameters to the screen fade.
		fadeInSpeed		= _inSpeed;
		fadeOutSpeed	= _outSpeed;
		fadeColor		= _color;
		
		// Determine whether to clear the bit that allows for an automatic fade out or set it.
		if (_manualFadeOut) { flags = flags & ~FADE_FLAG_ALLOW_FADE_OUT; }
		else				{ flags = flags | FADE_FLAG_ALLOW_FADE_OUT; }
		
		// Finally, let the game itself know a transition effect is occur so entities and objects can process
		// themselves accordingly. On top of that, set the player to their transition effect state until this
		// global flag is cleared once again.
		global.flags    = global.flags | GAME_FLAG_TRANSITION_ACTIVE;
	}
	
	/// @description 
	///	A simple state that sets the screen to fade itself into the desired color at the current fade in speed.
	/// Once it reaches full opacity (Alpha is 1.0 or higher), the screen fade will either begin fading out or
	/// waiting for the flag that allows the screen to begin fading out if a manual fade was chosen.
	///
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_fade_in = function(_delta){
		alpha += fadeInSpeed * _delta;
		if (alpha >= 1.0){ // Screen has successfully faded itself to the desired color.
			alpha = 1.0;
			if (FADE_CAN_FADE_OUT)
				object_set_state(state_fade_out);
		}
	}
	
	/// @description 
	///	Another simple state that sets the screen to fade from the desired color back to whatever was visible
	/// on the viewport prior to the screen's fade effect beginning. Once it reaches complete transparency,
	/// the screen fade will end and the game will return back to the state it was in prior to the fade effect.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_fade_out = function(_delta){
		alpha -= fadeOutSpeed * _delta;
		if (alpha <= 0.0){ // Screen has faded out; reset back to game's pre-screen fade state.
			object_set_state(0);
			flags		    = flags & ~FADE_FLAG_ACTIVE;
			alpha			= 0.0;
			
			// Let the game know a transition effect is no longer occuring so entities and objects can go back
			// to their previous states/logic if they were affected by transitions.
			global.flags    = global.flags & ~GAME_FLAG_TRANSITION_ACTIVE;
		}
	}
}

#endregion Screen Fade Struct Definition