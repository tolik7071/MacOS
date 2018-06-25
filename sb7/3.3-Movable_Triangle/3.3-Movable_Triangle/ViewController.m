//
//  ViewController.m
//  3.3-Movable_Triangle
//
//  Created by tolik7071 on 4/3/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#import <CoreVideo/CoreVideo.h>
#import "GLUtilities.h"

@implementation ViewController
{
    GLuint  _programID;
    GLuint  _VAO;
}

- (void)cleanup
{
   [super cleanup];

   if (0 != _programID)
   {
      glDeleteProgram(_programID);
   }

   if (0 != _VAO)
   {
      glDeleteVertexArrays(1, &_VAO);
   }
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    NSURL *vertexShader = FindResourceWithName(@"triangle.vert");
    NSAssert(vertexShader, @"Cannot find shader.");
    NSData *vertexShaderContent = ReadFile(vertexShader);
    NSAssert([vertexShaderContent length] > 0, @"Empty shader.");
    
    NSURL *fragmentShader = FindResourceWithName(@"triangle.frag");
    NSAssert(fragmentShader, @"Cannot find shader.");
    NSData *fragmentShaderContent = ReadFile(fragmentShader);
    NSAssert([fragmentShaderContent length] > 0, @"Empty shader.");
    
    _programID = CreateProgram(vertexShaderContent, fragmentShaderContent);
    NSAssert(_programID != 0, @"Cannot compile program.");
    
    glGenVertexArrays(1, &_VAO);
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    if (0 != _programID)
    {
        const GLfloat backgroundColor[] = { 0.0f, 0.2f, 0.0f, 1.0f };
        glClearBufferfv(GL_COLOR, 0, backgroundColor);
        
        glBindVertexArray(_VAO);
        
        // Use the program object we created earlier for rendering
        
        glUseProgram(_programID);
        
        // Draw one triangle
        
        // Update the value of input attribute 0
        {
            GLfloat offset[] =
            {
                (float)sin(currentTime) * 0.5f,
                (float)cos(currentTime) * 0.6f,
                0.0f,
                0.0f
            };
        
            glVertexAttrib4fv(0, offset);
        }
        
        // Update the value of input attribute 1
        {
            GLfloat color[] =
            {
                (float)sin(currentTime) * 0.5f + 0.5f,
                (float)cos(currentTime) * 0.5f + 0.5f,
                0.0f,
                1.0f
            };
            
            glVertexAttrib4fv(1, color);
        }
        
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
