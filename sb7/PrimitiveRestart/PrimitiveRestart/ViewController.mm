//
//  ViewController.m
//  PrimitiveRestart
//
//  Created by tolik7071 on 6/28/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#include <vector>

struct vertex
{
    float x;
    float y;
};

@implementation ViewController
{
    GLuint          _programID;
    GLuint          _VAO;
    GLuint          _VBO;
    GLuint          _EBO;
    GLsizei         _numverOfindexes;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _programID)
    {
        glDeleteProgram(_programID);
        _programID = 0;
    }
    
    if (0 != _VAO)
    {
        glDeleteVertexArrays(1, &_VAO);
        _VAO = 0;
    }
    
    if (0 != _VBO)
    {
        glDeleteBuffers(1, &_VBO);
    }
    
    if (0 != _EBO)
    {
        glDeleteBuffers(1, &_EBO);
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
    
    /* Fill our vertex and index buffers. 0xFFFF is our primitive restart value. */
    int num_particles = 3;
    int num_points = 40;
    std::vector<int> indices;
    std::vector<vertex> vertices;
    
    for (int i = 0; i < num_particles; ++i)
    {
        for (int j = 0; j < num_points; ++j)
        {
            indices.push_back((int)vertices.size());
            vertices.push_back(vertex{100 + i * 10.0f, 100 + j * 5.0f});
        }
        
        indices.push_back(0xFFFF);
    }
    
    _numverOfindexes = (GLsizei)indices.size();
    
    glGenBuffers(1, &_VBO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex) * vertices.size(), &vertices[0].x, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * indices.size(), &indices[0], GL_STATIC_DRAW);
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(vertex), (void*)0);
    
    _programID = CreateProgram(@"shader.vert", @"shader.frag");
    
    float pm[16] = { 0.0f };
    pm[0] = 2.0 / self.openGLView.frame.size.width;
    pm[5] = 2.0f / - self.openGLView.frame.size.height;
    pm[10] = -1.0f;
    pm[12] = -1.0;
    pm[13] = 1.0f;
    pm[15] = 1.0f;
    
    GLint u_pm = glGetUniformLocation(_programID, "u_pm");
    GLint u_color = glGetUniformLocation(_programID, "u_color");
    
    glUseProgram(_programID);
    
    glUniformMatrix4fv(u_pm, 1, GL_FALSE, pm);
    glUniform3f(u_color, 1.0f, 1.0f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    //glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    static const GLfloat green[] = { 0.0f, 0.25f, 0.0f, 1.0f };
    static const GLfloat one = 1.0f;
    
    glClearBufferfv(GL_COLOR, 0, green);
    glClearBufferfv(GL_DEPTH, 0, &one);
    
    if (0 != _programID)
    {
        glUseProgram(_programID);
        
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        
        /*
            This is where we enable primitive restart; Note that we have one draw call
            but we're drawing multiple separate GL_LINE_STRIPs.
         */
        glEnable(GL_PRIMITIVE_RESTART);
        glPrimitiveRestartIndex(0xFFFF);
        glUseProgram(_programID);
        glBindVertexArray(_VAO);
        glDrawElements(GL_LINE_STRIP, _numverOfindexes, GL_UNSIGNED_INT, (GLvoid*)0);

    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
