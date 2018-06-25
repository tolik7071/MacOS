//
//  ViewController.m
//  first_shader
//
//  Created by tolik7071 on 3/29/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);
NSURL* FindResourceWithName(NSString*);
NSData* ReadFile(NSURL*);
GLuint CreateProgram(NSData*, NSData*);

@implementation ViewController
{
    id                  _monitor;
    CVDisplayLinkRef    _displayLink;
    GLfloat             _deltaTime;
    GLfloat             _lastFrame;
    GLuint              _programID;
    GLuint              _VAO;
}

- (void)dealloc
{
    [self cleanup];
}

- (void)cleanup
{
    if (NULL != _displayLink)
    {
        CVDisplayLinkStop(_displayLink);
        CVDisplayLinkRelease(_displayLink);
        _displayLink = NULL;
    }
    
    if (nil != _monitor)
    {
        [NSEvent removeMonitor:_monitor];
        _monitor = nil;
    }
    
    if (0 != _programID)
    {
        glDeleteProgram(_programID);
    }
    
    if (0 != _VAO)
    {
        glDeleteVertexArrays(1, &_VAO);
    }
}

- (void)configOpenGLView
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
        NSOpenGLPFAOpenGLProfile        , NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize            , 32                           ,
        NSOpenGLPFAAlphaSize            , 8                            ,
        NSOpenGLPFADepthSize            , 24                           ,
        NSOpenGLPFADoubleBuffer         ,
        NSOpenGLPFAAccelerated          ,
        NSOpenGLPFANoRecovery           ,
        NSOpenGLPFAAllowOfflineRenderers,
        0
    };
    
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
    
    self.openGLView.pixelFormat = pixelFormat;
    self.openGLView.openGLContext = context;
    
#if defined(DEBUG)
    CGLEnable([context CGLContextObj], kCGLCECrashOnRemovedFunctions);
#endif
    
    self.openGLView.wantsBestResolutionOpenGLSurface = YES;
}

- (void)configDisplayLink
{
    CVReturn status = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    
    if (kCVReturnSuccess == status)
    {
        CVDisplayLinkSetOutputCallback(_displayLink, DisplayCallback, (__bridge void * _Nullable)(self));
        
        CGLContextObj cglContext = [self.openGLView.openGLContext CGLContextObj];
        CGLPixelFormatObj cglPixelFormat = [self.openGLView.pixelFormat CGLPixelFormatObj];
        CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
        
        CVDisplayLinkStart(_displayLink);
        
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(windowWillClose:)
            name:NSWindowWillCloseNotification
            object:[self.view window]];
    }
    else
    {
        NSLog(@"Display Link created with error: %d", status);
    }
}

- (void)windowWillClose:(NSNotification*)notification
{
    [self cleanup];
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    NSURL *vertexShader = FindResourceWithName(@"shader.vert");
    NSAssert(vertexShader, @"Cannot find shader.");
    NSData *vertexShaderContent = ReadFile(vertexShader);
    NSAssert([vertexShaderContent length] > 0, @"Empty shader.");
    
    NSURL *fragmentShader = FindResourceWithName(@"shader.frag");
    NSAssert(fragmentShader, @"Cannot find shader.");
    NSData *fragmentShaderContent = ReadFile(fragmentShader);
    NSAssert([fragmentShaderContent length] > 0, @"Empty shader.");
    
    _programID = CreateProgram(vertexShaderContent, fragmentShaderContent);
    NSAssert(_programID != 0, @"Cannot compile program.");
    
    //glCreateVertexArrays(1, &_VAO);
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
}

- (void)renderForTime:(CVTimeStamp)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    GLfloat currentTime = (GLfloat)(time.videoTime) / (GLfloat)(time.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    if (0 != _programID)
    {
        const GLfloat color[] =
        {
            (float)sin(currentTime) * 0.5f + 0.5f,
            (float)cos(currentTime) * 0.5f + 0.5f,
            0.0f,
            1.0f
        };
        glClearBufferfv(GL_COLOR, 0, color);
        
        // Use the program object we created earlier for rendering
        
        glUseProgram(_programID);
        
        // Draw one point
        
        glPointSize(40.0f);
        glDrawArrays(GL_POINTS, 0, 1);
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configOpenGLView];
    
    [self configOpenGLEnvironment];
    
    [self configDisplayLink];
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    [self.openGLView.openGLContext makeCurrentContext];
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

NSURL* FindResourceWithName(NSString* aName)
{
    NSURL *result = [[NSBundle mainBundle]
        URLForResource:[aName stringByDeletingPathExtension]
        withExtension:[aName pathExtension]];
    
    return result;
}

NSData* ReadFile(NSURL* anURL)
{
    NSData *bytes = nil;
    
    if (anURL && [[NSFileManager defaultManager] isReadableFileAtPath:[anURL path]])
    {
        NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingFromURL:anURL error:nil];
        bytes = [fileHandle readDataToEndOfFile];
    }
    
    return bytes;
}

GLuint CreateProgram(NSData *vertex, NSData *fragment)
{
    GLuint program = 0;
    GLchar *vertexBuffer = NULL;
    GLchar *fragmentBuffer = NULL;
    GLuint vertex_shader = 0;
    GLuint fragment_shader = 0;
    
    do
    {
        GLint length = 0;
        
        // Create and compile vertex shader
        
        length = (GLint)vertex.length;
        vertexBuffer = (GLchar *)malloc(length);
        if (!vertexBuffer)
        {
            break;
        }
        [vertex getBytes:vertexBuffer length:length];
        
        vertex_shader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertex_shader, 1, (const GLchar **)&vertexBuffer, &length);
        glCompileShader(vertex_shader);
        
        // Create and compile fragment shader
        
        length = (GLint)fragment.length;
        fragmentBuffer = (GLchar *)malloc(length);
        if (!fragmentBuffer)
        {
            break;
        }
        [fragment getBytes:fragmentBuffer length:length];
        
        fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragment_shader, 1, (const GLchar **)&fragmentBuffer, &length);
        glCompileShader(fragment_shader);
        
        // Create program, attach shaders to it, and link it
        
        program = glCreateProgram();
        glAttachShader(program, vertex_shader);
        glAttachShader(program, fragment_shader);
        glLinkProgram(program);
        
    } while (NO);
    
    // Free buffers
    
    if (vertexBuffer)
    {
        free(vertexBuffer);
    }
    
    if (fragmentBuffer)
    {
        free(fragmentBuffer);
    }
    
    // Delete the shaders as the program has them now
    
    if (vertex_shader != 0)
    {
        glDeleteShader(vertex_shader);
    }
    
    if (fragment_shader != 0)
    {
        glDeleteShader(fragment_shader);
    }
    
    return program;
}
