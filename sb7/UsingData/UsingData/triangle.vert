#version 330

// 'position' and 'color' are input vertex attributes
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 color;

// 'vs_color' is an output that will be sent to the next shader stage
out vec4 vs_color;

void main(void)
{
    // Index into our array using gl_VertexID
    gl_Position = vec4(position, 1.0);
    
    // Output a fixed value for vs_color
    vs_color = vec4(color, 1.0);
}
