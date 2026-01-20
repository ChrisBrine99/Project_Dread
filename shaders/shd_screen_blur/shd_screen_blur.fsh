varying vec2	vTexcoord;
varying vec4	vColour;

uniform vec2	texelSize;
uniform vec2	blurDirection;
uniform float	blurSteps;
uniform float	sigma;

//
float weight(float _position){
	return exp(-(_position * _position) / (2.0 * sigma * sigma));
}

void main(void){
	// 
	vec4	_texColor		= texture2D(gm_BaseTexture, vTexcoord);
	float	_kernel			= 2.0 * blurSteps + 1.0;
	float	_totalWeight	= 1.0;
	
	// 
	vec2	_sample;
	float	_weight;
	for (float offset = 1.0; offset <= blurSteps; offset++) {
		// 
		_weight			= weight(offset / _kernel);
		_totalWeight   += 2.0 * _weight;
		
		// 
		_sample			= vTexcoord - offset * texelSize * blurDirection;
		_texColor	   += texture2D(gm_BaseTexture, _sample) * _weight;
		
		// 
		_sample			= vTexcoord + offset * texelSize * blurDirection;
		_texColor	   += texture2D(gm_BaseTexture, _sample) * _weight;
	}
	
	// 
    gl_FragColor = vColour * _texColor / _totalWeight;
}
