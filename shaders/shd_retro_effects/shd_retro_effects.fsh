varying vec2	vPosition;
varying vec3	vColor;
varying vec2	vTexcoord;

uniform float	scanlineFactor;
uniform float	quantizeLevel;
uniform float	ditherMatrix[16];
uniform vec2	viewportSize;
uniform bool	quantizationActive;
uniform bool	ditheringActive;
uniform bool	scanlinesActive;

void main(void) {
	// Since the alpha channel isn't required for the effects applied in the shader, only the RGB values of the
	// texture and vertex color vector are sampled. Then, the value 1.0 is set for the output fragment's alpha.
	vec3 _currentColor = vColor * texture2D(gm_BaseTexture, vTexcoord).rgb;
	
	// A small optimization that turns this shader into a simple passthrough if all effects happen to be
	// disabled by the player at the same time.
	if (!quantizationActive && !ditheringActive && !scanlinesActive){
		gl_FragColor = vec4(_currentColor, 1.0);
		return;
	}
	
	// Determines which value index of the "ditherMatrix" array will be used for the current pixel being 
	// processed for output. The index value is truncated to ensure it is between the values 0 and 15.
	float _noise = 0.0;
	if (ditheringActive){
		float	_screenY	= floor(vTexcoord.y * viewportSize.y);			// Scale the screen coordinates to match the application surface's dimensions.
		float	_screenX	= floor(vTexcoord.x * viewportSize.x);
		int		_matIndex	= int(mod(_screenY * 4.0 + _screenX, 16.0));	// Determine the index relative to the pixel's position on screen.
		float	_denom		= 255.0 / quantizeLevel;						// Calculate range for dither values relative to quantize level.
		_noise				= ditherMatrix[_matIndex] / _denom;				// Grab the range value and reduce it to match the desired color depth.
	
		if (!quantizationActive) // Applying dithering if quantization happens to be inactive.
			_currentColor = clamp(floor(_currentColor * 255.0 + _noise), vec3(0.0), vec3(255.0)) / 255.0;
	}
	
	// Apply the quantization effect to reduce the output values color depth to what is specified by the 
	// uniform value for it. The calculated value is clamped to avoid exceeding the valid range of colors 
	// before the value is again divided to revert back to a value range of 0.0 to 1.0.
	if (quantizationActive){
		_currentColor = clamp(floor(_currentColor * quantizeLevel + _noise), vec3(0.0), vec3(quantizeLevel));
		_currentColor = _currentColor / quantizeLevel;
	}
	
	// Applies a "scanline" effect for every odd line of pixels on the application's output. The intensity of
	// the effect is determine by the uniform value for its factor--where 1.0 is no change and 0.0 is completely
	// blacking out that line of pixels.
	if (scanlinesActive && mod(floor(vPosition.y), 2.0) != 0.0)
		_currentColor = _currentColor * scanlineFactor;
    gl_FragColor = vec4(_currentColor, 1.0);
}
