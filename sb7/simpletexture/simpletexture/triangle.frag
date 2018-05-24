#version 330

uniform sampler2D s;

out vec4 color;

void main(void)
{
    color = texture(s, gl_FragCoord.xy / textureSize(s, 0));
}
