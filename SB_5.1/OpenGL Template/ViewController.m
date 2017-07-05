//
//  ViewController.m
//  OpenGL Template
//
//  Created by tolik7071 on 5/29/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>

//#define DRAW_FRAME_ONLY

CVReturn DisplayCallback(
    CVDisplayLinkRef,
    const CVTimeStamp*,
    const CVTimeStamp*,
    CVOptionFlags,
    CVOptionFlags*,
    void*);

GLuint CompileShader(const GLchar *source, GLenum type);
GLboolean LinkProgram(GLuint program);

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
#if defined(DRAW_FRAME_ONLY)
    GLfloat vertices[] = {
        // First triangle
         0.5f,  0.5f, 0.0f, // Top Right
         0.5f, -0.5f, 0.0f, // Bottom Right
        -0.5f,  0.5f, 0.0f, // Top Left

        // Second triangle
         0.5f, -0.5f, 0.0f, // Bottom Right
        -0.5f, -0.5f, 0.0f, // Bottom Left
        -0.5f,  0.5f, 0.0f  // Top Left
    };
#else
    GLfloat vertices[] =
    {
         0.5f,  0.5f, 0.0f,  // Top Right
         0.5f, -0.5f, 0.0f,  // Bottom Right
        -0.5f, -0.5f, 0.0f,  // Bottom Left
        -0.5f,  0.5f, 0.0f   // Top Left
    };
#endif //DRAW_FRAME_ONLY
    
    GLuint indices[] =
    {
        0, 1, 3,  // First Triangle
        1, 2, 3   // Second Triangle
    };
    
    glGenVertexArrays(1, &_VAO);
    glGenBuffers(1, &_VBO);
    glGenBuffers(1, &_EBO);
    
    glBindVertexArray(_VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glBindVertexArray(0);
}

- (void)setupCoordinates
{
    
}

- (void)renderForTime:(CVTimeStamp)time
{
    [self.openGLView.openGLContext makeCurrentContext];
    
#if defined(DRAW_FRAME_ONLY)
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
#endif // DRAW_FRAME_ONLY
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.shaderProgram);
    
    glBindVertexArray(_VAO);
    
#if defined(DRAW_FRAME_ONLY)
    glDrawArrays(GL_TRIANGLES, 0, 6);
#else
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
#endif // DRAW_FRAME_ONLY
    
    glBindVertexArray(0);
    
    [self.openGLView.openGLContext flushBuffer];
}

- (BOOL)processEvent:(NSEvent *)event
{
    const GLubyte *version = glGetString(GL_VERSION);
    NSLog(@"Version: %s", version);
    
    GLint attribute;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &attribute);
    NSLog(@"Maximum nr of vertex attributes supported: %d", attribute);
    
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
