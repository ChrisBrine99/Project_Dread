varying vec2 vPosition;
varying vec2 vTexcoord;
varying vec4 vColor;

uniform vec2 playerPos;

void main(void){
	// Grab the texel of what is currently being drawn, so its alpha can be properly adjusted based on its distance
	// to the player on the screen.
	vec4 _texColor	= vColor * texture2D(gm_BaseTexture, vTexcoord);
	
	// Calculate the distance between the player and the current point on the vertex that is being processed. Then,
	// lerp the value of that distance over the radius of the "hole punch" between 0.0 and 1.0. This value is used
	// to adjust the final alpha of the fragment.
	float _x		= playerPos.x - vPosition.x;
	float _y		= playerPos.y - vPosition.y;
	float _distance = sqrt(_x * _x + _y * _y);
	float _alpha	= mix(0.0, 1.0, _distance / 32.0);
	
	// Finally, pass the output alpha and texture information to the GPU so it can be drawn.
    gl_FragColor	= vec4(_texColor.rgb, _texColor.a * _alpha);
}
