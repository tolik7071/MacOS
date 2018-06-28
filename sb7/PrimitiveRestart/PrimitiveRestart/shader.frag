#version 330

uniform vec3 u_color;

layout (location = 0) out vec4 fragcolor;

void main(void)
{
    fragcolor = vec4(u_color, 1.0);
}
