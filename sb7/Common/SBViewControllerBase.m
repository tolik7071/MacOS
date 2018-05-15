//
//  SBViewControllerBase.m
//  OpenGL SB Tests
//
//  Created by tolik7071 on 4/3/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "SBViewControllerBase.h"
#import <OpenGL/gl3.h>

CVReturn DisplayCallback(CVDisplayLinkRef,const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

@implementation SBViewControllerBase
{
    BOOL _isInFullScreenMode;
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
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(windowWillEnterFullScreen:)
         name:NSWindowWillEnterFullScreenNotification
         object:[self.view window]];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(windowDidExitFullScreen:)
         name:NSWindowDidExitFullScreenNotification
         object:[self.view window]];
    }
    else
    {
        NSLog(@"Display Link created with error: %d", status);
    }
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
    _isInFullScreenMode = YES;
}

- (void)windowDidExitFullScreen:(NSNotification *)notification
{
    _isInFullScreenMode = NO;
}

- (void)windowWillClose:(NSNotification*)notification
{
    if (!_isInFullScreenMode)
    {
        [self cleanup];
    }
}

- (void)configOpenGLEnvironment
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)renderForTime:(MyTimeStamp *)time
{
    [self doesNotRecognizeSelector:_cmd];
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
    SBViewControllerBase *controller = (__bridge SBViewControllerBase *)displayLinkContext;
    [controller performSelectorOnMainThread:@selector(renderForTime:)
                                withObject:[[MyTimeStamp alloc] initWithTimeStamp:inOutputTime]
                             waitUntilDone:NO];

    return kCVReturnSuccess;
}
