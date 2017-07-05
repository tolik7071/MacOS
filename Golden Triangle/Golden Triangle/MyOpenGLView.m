//
//  MyOpenGLView.m
//  Golden Triangle
//
//  Created by Anatoliy Goodz on 5/22/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import "MyOpenGLView.h"
#include <OpenGL/gl.h>


static void DrawAnObject ()
{
    glColor3f(1.0f, 0.85f, 0.35f);
    
    glBegin(GL_TRIANGLES);
    {
        glVertex3f( 0.0,  0.6, 0.0);
        glVertex3f(-0.2, -0.3, 0.0);
        glVertex3f( 0.2, -0.3, 0.0);
    }
    
    glEnd();
}

static void ClearColorBuffer()
{
// TODO: visual artifacts!
//    static const GLfloat kBlackColor[] =
//    {
//        1.0f, 0.0f, 0.0f, 1.0f
//    };
    
//    glClearBufferfv(GL_COLOR, 0, kBlackColor);
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
}

@implementation MyOpenGLView

//- (instancetype)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format
//{
//    return [super initWithFrame:frameRect pixelFormat:format];
//}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [self setupViewport];
    
    ClearColorBuffer();
    
    DrawAnObject();
    
    glFlush();
}

#pragma mark -

 -(void)setupViewport
{
    [self  setWantsBestResolutionOpenGLSurface:YES];
    
    NSRect backingBounds = [self convertRectToBacking:[self bounds]];
    
    GLsizei backingPixelWidth = (GLsizei)(backingBounds.size.width),
    backingPixelHeight = (GLsizei)(backingBounds.size.height);
    
    glViewport(0, 0, backingPixelWidth, backingPixelHeight);
}

@end
