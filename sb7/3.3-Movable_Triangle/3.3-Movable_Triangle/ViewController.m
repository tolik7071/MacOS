//
//  ViewController.m
//  3.3-Movable_Triangle
//
//  Created by tolik7071 on 4/3/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"

#import <OpenGL/gl3.h>
#import "GLUtilities.h"

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

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
        const GLfloat backgroundColor[] = { 0.0f, 0.2f, 0.0f, 1.0f };
        glClearBufferfv(GL_COLOR, 0, backgroundColor);
        
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
