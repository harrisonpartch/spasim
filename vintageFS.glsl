varying vec2 v_Texcoords;

uniform sampler2D u_image;
uniform vec2 u_step;
const vec3 W = vec3(0.2125, 0.7154, 0.0721);

const int KERNEL_WIDTH = 7; // Odd
const float offset = 3.0;

// From stack overflow
float rand(vec2 val)
{
    return fract(sin(dot(val.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(void)
{
    vec3 accum = vec3(0.0);

	for (int i = 0; i < KERNEL_WIDTH; ++i)
	{
		for (int j = 0; j < KERNEL_WIDTH; ++j)
		{
			vec2 coord = vec2(v_Texcoords.s + ((float(i) - offset) * u_step.s), v_Texcoords.t + ((float(j) - offset) * u_step.t));
			accum += texture2D(u_image, coord).rgb;
		}
	}	

	float luminance = dot(texture2D(u_image, v_Texcoords).rgb, W);
	float noise = rand(vec2(v_Texcoords.s, v_Texcoords.t));
	float fromCenter = length(vec2(v_Texcoords.s - 0.5, v_Texcoords.t - 0.5));
	vec3 blur = accum / float(KERNEL_WIDTH * KERNEL_WIDTH) / 3.0;
	vec3 vintageTone = vec3(luminance)*(vec3(164.0, 155.0, 95.0)/255.0)/1.2;
	vec3 finalNoise = vec3(noise/10.0);
	vec4 finalColor = vec4(blur + vintageTone + finalNoise, 1.0);
	if (fromCenter > 0.3)
		gl_FragColor = vec4(finalColor.xyz * (1.0-(fromCenter-0.3)*3.0),1.0);
	else
		gl_FragColor = finalColor;
}
