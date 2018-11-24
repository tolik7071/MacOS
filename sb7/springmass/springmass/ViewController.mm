//
//  ViewController.m
//  springmass
//
//  Created by tolik7071 on 10/17/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import "GLUtilities.h"
#include <vector>
#include <vmath.h>

enum BUFFER_TYPE_t
{
    POSITION_A,
    POSITION_B,
    VELOCITY_A,
    VELOCITY_B,
    CONNECTION
};

enum
{
    POINTS_X            = 50,
    POINTS_Y            = 50,
    POINTS_TOTAL        = (POINTS_X * POINTS_Y),
    CONNECTIONS_TOTAL   = (POINTS_X - 1) * POINTS_Y + (POINTS_Y - 1) * POINTS_X
};

@implementation ViewController
{
    GLuint _update_program;
    GLuint _render_program;
    GLuint _vao[2];
    GLuint _vbo[5];
    GLuint _pos_tbo[2];
    GLuint _index_buffer;
    int    _iterations_per_frame;
    GLuint _iteration_index;
    bool   _draw_points;
    bool   _draw_lines;
    SB_FPS_Counter *_counter;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        _counter = [[SB_FPS_Counter alloc] init];
    }
    
    return self;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _update_program)
    {
        glDeleteProgram(_update_program);
        _update_program = 0;
    }
    
    if (0 != _render_program)
    {
        glDeleteProgram(_render_program);
        _render_program = 0;
    }
    
    if (0 != _vbo[0])
    {
        glDeleteBuffers(5, _vbo);
        _vbo[0] = 0;
    }
    
    if (0 != _vao[0])
    {
        glDeleteVertexArrays(2, _vao);
        _vao[0] = 0;
    }
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    glViewport(0, 0, self.openGLView.bounds.size.width, self.openGLView.bounds.size.height);
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    [self loadShaders];
    
    vmath::vec4 *initial_positions = new vmath::vec4 [POINTS_TOTAL];
    vmath::vec3 *initial_velocities = new vmath::vec3 [POINTS_TOTAL];
    vmath::ivec4 *connection_vectors = new vmath::ivec4 [POINTS_TOTAL];
    
    int i, j;
    int n = 0;
    
    for (j = 0; j < POINTS_Y; j++)
    {
        float fj = (float)j / (float)POINTS_Y;
        
        for (i = 0; i < POINTS_X; i++)
        {
            float fi = (float)i / (float)POINTS_X;
            
            initial_positions[n] = vmath::vec4(
                (fi - 0.5f) * (float)POINTS_X,
                (fj - 0.5f) * (float)POINTS_Y,
                0.6f * sinf(fi) * cosf(fj),
                1.0f
            );
            initial_velocities[n] = vmath::vec3(0.0f);
            
            connection_vectors[n] = vmath::ivec4(-1);
            
            if (j != (POINTS_Y - 1))
            {
                if (i != 0)
                    connection_vectors[n][0] = n - 1;
                
                if (j != 0)
                    connection_vectors[n][1] = n - POINTS_X;
                
                if (i != (POINTS_X - 1))
                    connection_vectors[n][2] = n + 1;
                
                if (j != (POINTS_Y - 1))
                    connection_vectors[n][3] = n + POINTS_X;
            }
            
            n++;
        }
    }
    
    glGenVertexArrays(2, _vao);
    glGenBuffers(5, _vbo);
    
    for (i = 0; i < 2; i++)
    {
        glBindVertexArray(_vao[i]);
        
        glBindBuffer(GL_ARRAY_BUFFER, _vbo[POSITION_A + i]);
        glBufferData(GL_ARRAY_BUFFER, POINTS_TOTAL * sizeof(vmath::vec4), initial_positions, GL_DYNAMIC_COPY);
        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, NULL);
        glEnableVertexAttribArray(0);
        
        glBindBuffer(GL_ARRAY_BUFFER, _vbo[VELOCITY_A + i]);
        glBufferData(GL_ARRAY_BUFFER, POINTS_TOTAL * sizeof(vmath::vec3), initial_velocities, GL_DYNAMIC_COPY);
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        glEnableVertexAttribArray(1);
        
        glBindBuffer(GL_ARRAY_BUFFER, _vbo[CONNECTION]);
        glBufferData(GL_ARRAY_BUFFER, POINTS_TOTAL * sizeof(vmath::ivec4), connection_vectors, GL_STATIC_DRAW);
        glVertexAttribIPointer(2, 4, GL_INT, 0, NULL);
        glEnableVertexAttribArray(2);
    }
    
    delete [] connection_vectors;
    delete [] initial_velocities;
    delete [] initial_positions;
    
    glGenTextures(2, _pos_tbo);
    glBindTexture(GL_TEXTURE_BUFFER, _pos_tbo[0]);
    glTexBuffer(GL_TEXTURE_BUFFER, GL_RGBA32F, _vbo[POSITION_A]);
    glBindTexture(GL_TEXTURE_BUFFER, _pos_tbo[1]);
    glTexBuffer(GL_TEXTURE_BUFFER, GL_RGBA32F, _vbo[POSITION_B]);
    
    int lines = (POINTS_X - 1) * POINTS_Y + (POINTS_Y - 1) * POINTS_X;
    
    glGenBuffers(1, &_index_buffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _index_buffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, lines * 2 * sizeof(int), NULL, GL_STATIC_DRAW);
    
    int * e = (int *)glMapBufferRange(
        GL_ELEMENT_ARRAY_BUFFER,
        0,
        lines * 2 * sizeof(int),
        GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
    
    for (j = 0; j < POINTS_Y; j++)
    {
        for (i = 0; i < POINTS_X - 1; i++)
        {
            *e++ = i + j * POINTS_X;
            *e++ = 1 + i + j * POINTS_X;
        }
    }
    
    for (i = 0; i < POINTS_X; i++)
    {
        for (j = 0; j < POINTS_Y - 1; j++)
        {
            *e++ = i + j * POINTS_X;
            *e++ = POINTS_X + i + j * POINTS_X;
        }
    }
    
    glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);
    
    _draw_points = true;
    _draw_lines = true;
    _iterations_per_frame = 16;
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [_counter increase];
    [self.fps setStringValue:[NSString stringWithFormat:@"%.02f", [_counter fps]]];
    
    static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 0.0f };
    
    glViewport(0, 0, self.openGLView.frame.size.width, self.openGLView.frame.size.height);
    glClearBufferfv(GL_COLOR, 0, black);
    
    if (0 != _update_program)
    {
        glUseProgram(_update_program);
        
        glEnable(GL_RASTERIZER_DISCARD);
        
        for (int i = _iterations_per_frame; i != 0; --i)
        {
            glBindVertexArray(_vao[_iteration_index & 1]);
            glBindTexture(GL_TEXTURE_BUFFER, _pos_tbo[_iteration_index & 1]);
            _iteration_index++;
            glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, _vbo[POSITION_A + (_iteration_index & 1)]);
            glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 1, _vbo[VELOCITY_A + (_iteration_index & 1)]);
            glBeginTransformFeedback(GL_POINTS);
            glDrawArrays(GL_POINTS, 0, POINTS_TOTAL);
            glEndTransformFeedback();
        }
        
        glDisable(GL_RASTERIZER_DISCARD);
    }
    
    if (0 != _render_program)
    {
        glUseProgram(_render_program);
        
        if (_draw_points)
        {
            glPointSize(4.0f);
            glDrawArrays(GL_POINTS, 0, POINTS_TOTAL);
        }
        
        if (_draw_lines)
        {
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _index_buffer);
            glDrawElements(GL_LINES, CONNECTIONS_TOTAL * 2, GL_UNSIGNED_INT, NULL);
        }
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

- (void)loadShaders
{
    GLuint vs;
    GLuint fs;
    char buffer[1024];
    
    NSURL *url = FindResourceWithName(@"update.vs.glsl");
    assert(url);
    vs = CreateShader(ReadFile(url), GL_VERTEX_SHADER);
    
    if (0 != _update_program)
    {
        glDeleteProgram(_update_program);
    }
    
    _update_program = glCreateProgram();
    glAttachShader(_update_program, vs);
    
    static const char * tf_varyings[] =
    {
        "tf_position_mass",
        "tf_velocity"
    };
    
    glTransformFeedbackVaryings(_update_program, 2, tf_varyings, GL_SEPARATE_ATTRIBS);
    
    glLinkProgram(_update_program);
    
    glGetShaderInfoLog(vs, 1024, NULL, buffer);
    glGetProgramInfoLog(_update_program, 1024, NULL, buffer);
    
    glDeleteShader(vs);
    
    url = FindResourceWithName(@"render.vs.glsl");
    assert(url);
    vs = CreateShader(ReadFile(url), GL_VERTEX_SHADER);
    
    url = FindResourceWithName(@"render.fs.glsl");
    assert(url);
    fs = CreateShader(ReadFile(url), GL_FRAGMENT_SHADER);
    
    if (_render_program)
    {
        glDeleteProgram(_render_program);
    }
    
    _render_program = glCreateProgram();
    glAttachShader(_render_program, vs);
    glAttachShader(_render_program, fs);
    
    glLinkProgram(_render_program);
}

- (BOOL)processEvent:(NSEvent *)event
{
    BOOL processed = NO;
    
    if (event.type == NSEventTypeKeyDown)
    {
        switch(event.keyCode)
        {
            case /*kVK_ANSI_R*/0x0F:
            {
                [self loadShaders];
                break;
            }
                
            case /*kVK_ANSI_L*/0x25:
            {
                _draw_lines = !_draw_lines;
                break;
            }
                
            case /*kVK_ANSI_P*/0x23:
            {
                _draw_points = !_draw_points;
                break;
            }
                
            case /*kVK_ANSI_Equal*/0x18:
            {
                _iterations_per_frame++;
                break;
            }
                
            case /*kVK_ANSI_Minus*/0x1B:
            {
                _iterations_per_frame--;
                break;
            }
        }
    }
    else if (event.type == NSEventTypeScrollWheel)
    {
        
    }
    else if (event.type == NSEventTypeLeftMouseDragged)
    {
        NSPoint point = [self.openGLView convertPoint:[event locationInWindow] fromView:nil];
        
        if ([self.openGLView hitTest:point])
        {
            
        }
    }
    
    return processed;
}

@end
