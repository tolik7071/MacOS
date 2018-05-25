#version 330

uniform sampler2D s;

uniform float exposure;

out vec4 color;

void main(void)
{
    color = texture(s, gl_FragCoord.xy / textureSize(s, 0)) * exposure;
}
