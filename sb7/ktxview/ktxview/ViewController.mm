//
//  ViewController.m
//  ktxview
//
//  Created by tolik7071 on 5/25/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#import "GLUtilities.h"
#import "sb7ktx.h"

@implementation ViewController
{
    GLuint      _programID;
    GLuint      _VAO;
    GLuint      _texture;
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
    
    if (0 != _texture)
    {
        glDeleteTextures(1, &_texture);
        _texture = 0;
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
    
    glEnable(GL_DEPTH_TEST);
    
    _programID = CreateProgram(@"triangle.vert", @"triangle.frag");
    NSAssert(_programID != 0, @"Cannot compile program.");
    
    glUseProgram(_programID);
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    glActiveTexture(GL_TEXTURE0);
    
    glGenTextures(1, &_texture);
    
    NSURL *textureFileUrl = FindResourceWithName(@"tree.ktx");
    NSAssert(textureFileUrl, @"Texture file not found.");
    sb7::ktx::file::load([textureFileUrl fileSystemRepresentation], _texture);
    
    glBindTexture(GL_TEXTURE_2D, _texture);
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
    
    static const GLfloat green[] = { 0.0f, 0.25f, 0.0f, 1.0f };
    glClearBufferfv(GL_COLOR, 0, green);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    if (0 != _programID)
    {
        glUseProgram(_programID);
        glBindTexture(GL_TEXTURE_2D, _texture);
        glBindVertexArray(_VAO);
        glUniform1f(0, (float)(sin(currentTime) * 16.0 + 16.0));
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
