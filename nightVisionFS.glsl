varying vec2 v_Texcoords;

uniform sampler2D u_image;

// From stack overflow
float rand(vec2 val)
{
    return fract(sin(dot(val.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(void)
{
	float noise = rand(vec2(v_Texcoords.s, v_Texcoords.t));
	if (length(vec2(v_Texcoords.s - 0.5, v_Texcoords.t - 0.5)) > 0.45)
		gl_FragColor = vec4(vec3(0),1.0);
	else
		gl_FragColor = vec4(vec3(texture2D(u_image, v_Texcoords).xyz * vec3(0,1,0)) + vec3(noise/4.0), 1.0);
}
