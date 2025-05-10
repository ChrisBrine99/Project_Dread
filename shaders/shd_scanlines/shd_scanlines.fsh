varying float yPosition;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main(void) {
	if (mod(floor(yPosition), 2.0) == 0.0){
		gl_FragColor = mix(v_vColour, vec4(0.0), 0.15) * texture2D( gm_BaseTexture, v_vTexcoord );
		return;
	}
	gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
}
