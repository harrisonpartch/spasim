varying vec2 v_Texcoords;

uniform sampler2D u_image;
const vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main(void)
{
	float luminance = dot(texture2D(u_image, v_Texcoords).rgb, W);
	gl_FragColor = vec4(vec3(luminance),1.0);
}
