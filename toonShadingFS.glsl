varying vec2 v_Texcoords;

uniform sampler2D u_image;
uniform vec2 u_step;

const int KERNEL_WIDTH = 3; // Odd
const float offset = 1.0;
const vec3 W = vec3(0.3, 0.3, 0.3);
const mat3 vert = mat3(vec3(-1,-2,-1), vec3(0,0,0), vec3(1,2,1));
const mat3 hor = mat3(vec3(-1,0,1), vec3(-2,0,2), vec3(-1,0,1));

void main(void)
{
	vec3 color = texture2D(u_image, v_Texcoords).rgb;
	float luminance = dot(color, W);
	
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

	float len = length(vec2(accumHor, accumVert));
	if (len > 0.36)
		gl_FragColor = vec4(vec3(0),1.0);
	else
	{
		float quantize = 6.3;
		color.rgb *= quantize;
		color.rgb += vec3(0.5);
		ivec3 irgb = ivec3(color.rgb);
		color.rgb = vec3(irgb) / quantize;
		gl_FragColor = vec4(vec3(color), 1.0);
	}
}
