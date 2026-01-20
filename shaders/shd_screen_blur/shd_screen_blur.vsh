attribute vec2 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 vTexcoord;
varying vec4 vColour;

void main(void) {
    vec4 _oPos	= vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * _oPos;
    vColour		= in_Colour;
    vTexcoord	= in_TextureCoord;
}
