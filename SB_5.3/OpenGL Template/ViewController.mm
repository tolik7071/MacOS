//
//  ViewController.m
//  OpenGL Template
//
//  Created by tolik7071 on 5/29/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#include "vmath.h"

CVReturn DisplayCallback(
    CVDisplayLinkRef,
    const CVTimeStamp*,
    const CVTimeStamp*,
    CVOptionFlags,
    CVOptionFlags*,
    void*);

GLuint CompileShader(const GLchar *source, GLenum type);
GLboolean LinkProgram(GLuint program);

struct VertexData
{
    // Position
    GLfloat x;
    GLfloat y;
    GLfloat z;
    
    // Color
    GLfloat r;
    GLfloat g;
    GLfloat b;
};

@implementation ViewController
{
    GLuint _vertexArrayObject;
    id _monitor;
    GLuint _VBO, _VAO, _EBO;
}

- (void)dealloc
{
    if (0 != _shaderProgram)
    {
        glDeleteProgram(_shaderProgram);
    }
    
    if (NULL != _displayLink)
    {
        CVDisplayLinkStop(_displayLink);
        CVDisplayLinkRelease(_displayLink);
    }
    
    if (nil != _monitor)
    {
        [NSEvent removeMonitor:_monitor];
    }
    
    glDeleteVertexArrays(1, &_VAO);
    glDeleteBuffers(1, &_VBO);
    glDeleteBuffers(1, &_EBO);
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    if (NULL == _displayLink)
    {
        _monitor = [NSEvent addLocalMonitorForEventsMatchingMask:(NSKeyDownMask | NSFlagsChangedMask)
            handler:^NSEvent* (NSEvent* event)
        {
            [self processEvent:event];
            
            return event;
        }];
        
        // First call...
        [self createOpenGLView];
        [self.openGLView.openGLContext makeCurrentContext];
        [self setupCoordinates];
        [self loadShaders];
        [self loadBufferData];
        [self createDisplayLink];
    }
}

- (void)createOpenGLView
{
    NSAssert(self.view.window != nil, @"ERROR: There is no window");
    NSAssert(self.view == self.view.window.contentView, @"ERROR: %@ is not a content view", self.view);
    
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize    , 24                           ,
        NSOpenGLPFAAlphaSize    , 8                            ,
        NSOpenGLPFADoubleBuffer ,
        NSOpenGLPFAAccelerated  ,
        NSOpenGLPFANoRecovery   ,
        0
    };
    
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
    
    _openGLView = [[NSOpenGLView alloc] initWithFrame:self.view.window.contentView.frame
        pixelFormat:pixelFormat];
    
    [self.view.window.contentView addSubview:_openGLView];
    
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint
        constraintWithItem:self.openGLView
        attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual
        toItem:self.view
        attribute:NSLayoutAttributeTop
        multiplier:1.0
        constant:0];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
        constraintWithItem:self.openGLView
        attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual
        toItem:self.view
        attribute:NSLayoutAttributeTrailing
        multiplier:1.0
        constant:0];
    [self.view addConstraint:constraint];
    
    [self.view.window layoutIfNeeded];
}

- (void)createDisplayLink
{
    CGDirectDisplayID displayID = CGMainDisplayID();
    CVReturn error = CVDisplayLinkCreateWithCGDisplay(displayID, &_displayLink);
    
    if (kCVReturnSuccess == error)
    {
        CVDisplayLinkSetOutputCallback(_displayLink, DisplayCallback, (__bridge void * _Nullable)(self));
        CVDisplayLinkStart(_displayLink);
    }
    else
    {
        NSLog(@"Display Link created with error: %d", error);
    }
}

- (void)loadShaders
{
    NSURL *vertexShaderPath = [[NSBundle mainBundle] URLForResource:@"Shader" withExtension:@"vert"];
    NSURL *fragmentShaderPath = [[NSBundle mainBundle] URLForResource:@"Shader" withExtension:@"frag"];
    
    NSAssert(vertexShaderPath != nil && fragmentShaderPath != nil, @"ERROR: Cannot find shader");
    
    const GLchar *vertexShaderSource = (GLchar *)[[NSString stringWithContentsOfURL:vertexShaderPath
        encoding:NSASCIIStringEncoding error:nil] cStringUsingEncoding:NSASCIIStringEncoding];
    const GLchar *fragmentShaderSource = (GLchar *)[[NSString stringWithContentsOfURL:fragmentShaderPath
        encoding:NSASCIIStringEncoding error:nil] cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSAssert(vertexShaderSource != nil && fragmentShaderSource != nil, @"ERROR: Invalid shader source");
    
    GLuint vertexShaderId = CompileShader(vertexShaderSource, GL_VERTEX_SHADER);
    GLuint fragmentShaderId = CompileShader(fragmentShaderSource, GL_FRAGMENT_SHADER);
    
    NSAssert(vertexShaderId != (GLuint)(-1) && fragmentShaderId != (GLuint)(-1), @"ERROR: Cannot compile shader");
    
    _shaderProgram = glCreateProgram();
    
    glAttachShader(self.shaderProgram, vertexShaderId);
    glAttachShader(self.shaderProgram, fragmentShaderId);
    
    if (GL_TRUE != LinkProgram(self.shaderProgram))
    {
        NSLog(@"ERROR: Cannot link program");
        _shaderProgram = 0;
    }
    
    glDeleteShader(vertexShaderId);
    glDeleteShader(fragmentShaderId);
}

- (void)loadBufferData
{
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    static const GLfloat vertex_positions[] =
    {
        -0.25f,  0.25f, -0.25f,
        -0.25f, -0.25f, -0.25f,
         0.25f, -0.25f, -0.25f,
         0.25f, -0.25f, -0.25f,
         0.25f,  0.25f, -0.25f,
        -0.25f,  0.25f, -0.25f,
        
        /* MORE DATA HERE */
        
        -0.25f,  0.25f, -0.25f,
         0.25f,  0.25f, -0.25f,
         0.25f,  0.25f,  0.25f,
         0.25f,  0.25f,  0.25f,
        -0.25f,  0.25f,  0.25f,
        -0.25f,  0.25f, -0.25f
    };
    
    glGenBuffers(1, &_VBO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex_positions), vertex_positions, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);
}

- (void)setupCoordinates
{
    
}

- (void)renderForTime:(CVTimeStamp)time
{
    [self.openGLView.openGLContext makeCurrentContext];
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.shaderProgram);
    
    glBindVertexArray(_VAO);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glBindVertexArray(0);
    
    [self.openGLView.openGLContext flushBuffer];
}

- (BOOL)processEvent:(NSEvent *)event
{
    const GLubyte *version = glGetString(GL_VERSION);
    NSLog(@"Version: %s", version);
    
    return NO;
}

@end

CVReturn DisplayCallback(
    CVDisplayLinkRef displayLink,
    const CVTimeStamp *inNow,
    const CVTimeStamp *inOutputTime,
    CVOptionFlags flagsIn,
    CVOptionFlags *flagsOut,
    void *displayLinkContext)
{
    ViewController *controller = (__bridge ViewController *)displayLinkContext;
    [controller renderForTime:*inOutputTime];
    
    return kCVReturnSuccess;
}

GLuint CompileShader(const GLchar *source, GLenum type)
{
    assert(source != NULL && (
          type == GL_VERTEX_SHADER || type == GL_FRAGMENT_SHADER ||
          type == GL_TESS_CONTROL_SHADER || type == GL_TESS_EVALUATION_SHADER ||
          type == GL_GEOMETRY_SHADER
        )
    );
    
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (GL_FALSE == status)
    {
        glDeleteShader(shader);
        shader = (GLuint)(-1);
    }
    
    return shader;
}

GLboolean LinkProgram(GLuint program)
{
    GLboolean result = GL_TRUE;
    
    glLinkProgram(program);
    
    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (0 == status)
    {
        result = GL_FALSE;
    }
    
    return result;
}
