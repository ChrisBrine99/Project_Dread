varying float yPosition;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float scanlineIntensity;
uniform float quantizeLevel;

void main(void) {	
	vec4 baseColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	baseColor.rgb = floor(baseColor.rgb * quantizeLevel) / quantizeLevel;
	if (mod(floor(yPosition), 2.0) == 0.0)
		baseColor.rgb = mix(baseColor.rgb, vec3(0.0), scanlineIntensity);
    gl_FragColor = baseColor;
}
