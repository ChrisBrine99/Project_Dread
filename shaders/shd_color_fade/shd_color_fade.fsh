varying vec4	vColor;

uniform vec3	fadeColor;

void main(void){ // Simply return the color with its alpha adjusted based on the RGB value of the input color.
    gl_FragColor = vec4(fadeColor.rgb, vColor.a * ((vColor.r + vColor.g + vColor.b) / 3.0));
}
