#version 330

uniform mat4 u_pm;

layout (location = 0) in vec2 a_pos;

void main(void)
{
    gl_Position = u_pm * vec4(a_pos, 0.0, 1.0);
}
