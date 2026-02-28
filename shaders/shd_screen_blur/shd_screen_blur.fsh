varying vec2	vTexcoord;
varying vec4	vColor;

uniform vec2	texelSize;
uniform vec2	blurDirection;
uniform float	blurSteps;
uniform float	sigma;

/// @description 
///	Determines the "weight" of the texel. This is the amount of blending that will occur on the current fragment
/// color relative to this texel's color. As the distance from the fragment increases, the weight will decrease.
///
///	@param {Float} position		The position for the texel that is being weighed.
float weight(float _position){
	return exp(-(_position * _position) / (2.0 * sigma * sigma));
}

void main(void){
	// Store the base color of the fragment into a vector so it can be altered before being rendered. The kernel
	// is calculated relative to the amount of "steps" the blur will sample. Finally, the total weight is the
	// overall amount of sampling done on the fragment through the blurring process, which allows the final
	// output to be normalized between 0.0 and 1.0.
	vec3	_texColor		= texture2D(gm_BaseTexture, vTexcoord).rgb;
	float	_kernel			= 2.0 * blurSteps + 1.0;
	float	_totalWeight	= 1.0;
	
	// Loop for the total number of blur steps necessary along the current axis (The blurDirection uniform vector
	// will determine if the samples will be along the x or y axis). Each loop will sample a fragment that is x
	// pixels away from the current fragment on both sides.
	vec2	_sample;
	float	_weight;
	for (float offset = 1.0; offset <= blurSteps; offset++) {
		// Calculate the weight relative to the current offset. Then, add that weight to the current total (It is
		// multiplied by two since two samples are processed per iteration).
		_weight			= weight(offset / _kernel);
		_totalWeight   += 2.0 * _weight;
		
		// Sample the fragment towards -infinity on the axis being processed relative to the calculated weight.
		_sample			= vTexcoord - offset * texelSize * blurDirection;
		_texColor	   += texture2D(gm_BaseTexture, _sample).rgb * _weight;
		
		// Sample the fragment towards +infinity on the axis being processed relative to the calculated weight.
		_sample			= vTexcoord + offset * texelSize * blurDirection;
		_texColor	   += texture2D(gm_BaseTexture, _sample).rgb * _weight;
	}
	
	// Finally, combined the vertex color with the determined fragment color; converting that to a vec4 with an
	// alpha of 1.0.
    gl_FragColor = vColor * vec4(_texColor / _totalWeight, 1.0);
}
