#version 330

void main(void)
{
    const vec4 vertices[] = vec4[]
    (
        vec4( 0.4, -0.4, 0.5, 1.0),
        vec4(-0.4, -0.4, 0.5, 1.0),
        vec4( 0.4,  0.4, 0.5, 1.0),
        vec4(-0.4,  0.4, 0.5, 1.0)
    );
    
    gl_Position = vertices[gl_VertexID];
}
