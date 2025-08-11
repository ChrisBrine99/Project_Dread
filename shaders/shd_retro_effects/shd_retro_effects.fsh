varying vec2 v_vPosition;
varying vec2 v_vTexcoord;
varying vec3 v_vColour;

uniform float scanlineFactor;
uniform float quantizeLevel;
uniform float windowScale;
uniform float ditherMatrix[16];

void main(void) {
	// Since the alpha channel isn't required for the effects applied in the shader, only the RGB values of the
	// texture and vertex color vector are sampled. Then, the value 1.0 is set for the output fragment's alpha.
	vec3 _currentColor	= v_vColour * texture2D( gm_BaseTexture, v_vTexcoord ).rgb;
	
	// Determines which value index of the "ditherMatrix" array will be used for the current pixel being 
	// processed for output. The index value is truncated to ensure it is between the values 0 and 15.
	float	_yPos		= floor(v_vPosition.y / windowScale);	// Scale the screen coordinates to match the application surface's instead of the window's.
	float	_xPos		= floor(v_vPosition.x / windowScale);
	int		_matIndex	= int(mod(_yPos * 4.0 + _xPos, 16.0));	// Determine the index relative to the pixel's position on screen.
	float	_denom		= 255.0 / quantizeLevel;				// Calculate range for dither values relative to quantize level.
	float	_noise		= ditherMatrix[_matIndex] / _denom;		// Grab the range value and reduce it to match the desired color depth.
	
	// Apply the quantization effect to reduce the output values color depth to what is specified by the 
	// uniform value for it. The calculated value is clamps to avoid exceeding the valid range of colors before
	// the value is again divided to revert back to a value range of 0.0 to 1.0.
	_currentColor		= clamp(floor(_currentColor * quantizeLevel + _noise), vec3(0.0), vec3(quantizeLevel));
	_currentColor		= _currentColor / quantizeLevel;
	
	// Applies a "scanline" effect for every odd line of pixels on the application's output. The intensity of
	// the effect is determine by the uniform value for its factor--where 1.0 is no change and 0.0 is completely
	// blacking out that line of pixels.
	if (mod(floor(v_vPosition.y), 2.0) != 0.0)
		_currentColor	= _currentColor * scanlineFactor;
    gl_FragColor = vec4(_currentColor, 1.0);
}
