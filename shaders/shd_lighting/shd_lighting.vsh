attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;					 // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;

void main(){
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, 0.0, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	v_vTexcoord = in_TextureCoord;
}