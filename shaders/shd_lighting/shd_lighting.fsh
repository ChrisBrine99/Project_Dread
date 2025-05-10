varying vec2 v_vTexcoord;

uniform vec3		color;
uniform float		brightness;
uniform float		saturation;
uniform float		contrast;
uniform sampler2D	lightTex;

void main(){
	// Get the application surface's texel color (Alpha channel is ignored by the shader) and get its grayscale 
	// value through the dot product against that very friendly looking vec3 AKA the NTSC gray conversion vector.
	vec3 _texColor	= texture2D(gm_BaseTexture, v_vTexcoord).rgb;
	float _gray		= dot(_texColor, vec3(0.299, 0.587, 0.114));

	// Blends the unlit color found within the base texture with the light color passed in through the uniform
	// "color". After that, further adjustment to the resulting color's saturation, contrast, and brightness
	// to really finetune the result.
	vec3 _outColor = _gray > 0.5 ? 
						1.0 - (1.0 - 2.0 * (_texColor - 0.5)) * (1.0 - color) : 
						2.0 * _texColor * color;
	_outColor = mix(vec3(_gray), _outColor, saturation);
	_outColor = (_outColor - 0.5) * contrast + 0.5;
	_outColor = _outColor + brightness;
	
	// After the world lighting has been applied, the lighting texture is sample at the same texel and the two
	// colors are blended together to get the final fully-lighted color output of the texel.
	vec3 _lightColor	= texture2D(lightTex, v_vTexcoord).rgb;
	_gray				= dot(_lightColor, vec3(0.333)); // Changes from NTSC gray conversion to an even 33% RGB gray color.
	_outColor			= mix(_outColor, _texColor * normalize(_lightColor + 0.05) * 3.0, _gray) + (0.1 * _lightColor);
    gl_FragColor		= vec4(_outColor, 1.0); // Alpha is always set to 1.0.
}
