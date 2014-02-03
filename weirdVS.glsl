attribute vec4 Position;
attribute vec2 Texcoords;
varying vec2 v_Texcoords;

uniform vec2 u_step;

void main(void)
{
	v_Texcoords = Texcoords;
	if (Position.x <0.1)
		gl_Position = Position+0.5;
	else
	gl_Position = Position;
}