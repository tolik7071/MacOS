#version 410

// 'offset' and 'color' are input vertex attributes
layout (location = 0) in vec4 offset;
layout (location = 1) in vec4 color;

// 'vs_color' is an output that will be sent to the next shader stage
out vec4 vs_color;

void main(void)
{
    // Declare a hard-coded array of positions
    const vec4 vertices[3] = vec4[3]
    (
        vec4( 0.25, -0.25, 0.5, 1.0),
        vec4(-0.25, -0.25, 0.5, 1.0),
        vec4( 0.25,  0.25, 0.5, 1.0)
     );
    
    // Index into our array using gl_VertexID
    gl_Position = vertices[gl_VertexID] + offset;
    
    const vec4 colors[] = vec4[3]
    (
        vec4(1.0, 0.0, 0.0, 1.0),
        vec4(0.0, 1.0, 0.0, 1.0),
        vec4(0.0, 0.0, 1.0, 1.0)
    );
    
    // Output a fixed value for vs_color
//    vs_color = color;
    
    // Output a fixed value for vs_color
    vs_color = colors[gl_VertexID];
}
