//
//  ViewController.m
//  OpenGLTemplate
//
//  Created by tolik7071 on 10/2/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

@implementation ViewController
{
    id                  _monitor;
    CVDisplayLinkRef    _displayLink;
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
        _monitor= nil;
    }
}

- (void)configOpenGLView
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize    , 32                           ,
        NSOpenGLPFAAlphaSize    , 8                            ,
        NSOpenGLPFADepthSize    , 24                           ,
        NSOpenGLPFADoubleBuffer ,
        NSOpenGLPFAAccelerated  ,
        NSOpenGLPFANoRecovery   ,
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

- (void)configEventMonitor
{
    _monitor = [NSEvent addLocalMonitorForEventsMatchingMask:
    (NSEventMaskKeyDown | NSEventMaskScrollWheel)handler:^NSEvent* (NSEvent* event)
    {
        [self processEvent:event];
        return event;
    }];
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    GLuint VAO;
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configOpenGLView];
    
    [self configOpenGLEnvironment];
    
    [self configEventMonitor];
    
    [self configDisplayLink];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)renderForTime:(CVTimeStamp)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glClearColor(0.8f, 0.8f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.openGLView.openGLContext flushBuffer];
}

- (BOOL)processEvent:(NSEvent *)event
{
    if (event.type == NSEventTypeKeyDown)
    {
        switch(event.keyCode)
        {
            case /*kVK_ANSI_W*/0x0D:
            {
                break;
            }
            
            case /*kVK_ANSI_S*/0x01:
            {
                break;
            }
            
            case /*kVK_ANSI_A*/0x00:
            {
                break;
            }
            
            case /*kVK_ANSI_D*/0x02:
            {
                break;
            }
        }
    }
    else if (event.type == NSEventTypeScrollWheel)
    {
        
    }
    
    return YES;
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
