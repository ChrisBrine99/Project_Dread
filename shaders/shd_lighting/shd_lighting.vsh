attribute vec2	in_Position;
attribute vec2	in_TexCoord;

varying vec2	vTexcoord;

void main(void){
    vec4 _oPos	= vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * _oPos;
	vTexcoord	= in_TexCoord;
}