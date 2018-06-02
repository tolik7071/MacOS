#version 330

out vec4 color;

in VS_OUT
{
    vec2 tc;
} fs_in;

uniform sampler2D tex;

void main(void)
{
    color = texture(tex, fs_in.tc);
}
