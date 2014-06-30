varying vec2 v_Texcoords;

uniform sampler2D u_image;

void main(void)
{
    gl_FragColor = vec4(texture2D(u_image, v_Texcoords).xyz*1.3, 1.0);
}
