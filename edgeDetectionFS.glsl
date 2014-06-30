varying vec2 v_Texcoords;

uniform sampler2D u_image;
uniform vec2 u_step;

const int KERNEL_WIDTH = 3; // Odd
const float offset = 1.0;
const vec3 W = vec3(0.2, 0.2, 0.2);
const mat3 vert = mat3(vec3(-1,-2,-1), vec3(0,0,0), vec3(1,2,1));
const mat3 hor = mat3(vec3(-1,0,1), vec3(-2,0,2), vec3(-1,0,1));

void main(void)
{
	float luminance = dot(texture2D(u_image, v_Texcoords).rgb, W);
	
    float accumHor = 0.0;
	float accumVert = 0.0;

	for (int i = 0; i < KERNEL_WIDTH; ++i)
	{
		for (int j = 0; j < KERNEL_WIDTH; ++j)
		{
			vec2 coord = vec2(v_Texcoords.s + ((float(i) - offset) * u_step.s), v_Texcoords.t + ((float(j) - offset) * u_step.t));
			float dotProd = dot(texture2D(u_image, coord).rgb, W);
			accumHor +=  dotProd * hor[i][j];
			accumVert += dotProd * vert[i][j];
		}
	}	

    gl_FragColor = vec4(vec3(length(vec2(accumHor, accumVert))), 1.0);
}
