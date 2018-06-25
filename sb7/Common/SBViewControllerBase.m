//
//  SBViewControllerBase.m
//  OpenGL SB Tests
//
//  Created by tolik7071 on 4/3/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "SBViewControllerBase.h"
#import <OpenGL/gl3.h>

#define USE_HARDWARE_ACCELERATED_RENDERS

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
#if defined(USE_HARDWARE_ACCELERATED_RENDERS)
        NSOpenGLPFAAccelerated          ,
        NSOpenGLPFANoRecovery           ,
#else
        NSOpenGLPFARendererID           ,
        kCGLRendererGenericFloatID      ,
#endif // USE_HARDWARE_ACCELERATED_RENDERS
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
        
        CVDisplayLinkStart(_displayLink);
    }
    else
    {
        NSLog(@"Display Link created with error: %d", status);
    }
}

- (void)configEventMonitor
{
    _monitor = [NSEvent addLocalMonitorForEventsMatchingMask:
        (NSEventMaskKeyDown | NSEventMaskScrollWheel | NSEventMaskLeftMouseDragged)handler:^NSEvent* (NSEvent* event)
        {
            BOOL processed = [self processEvent:event];
            return processed ? nil : event;
        }];
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
    
    [self configEventMonitor];
}

- (void)viewDidLayout
{
   [super viewDidLayout];

   [self.openGLView.openGLContext makeCurrentContext];
}

- (BOOL)processEvent:(NSEvent *)event
{
    /*
     file://Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
     */
    
    BOOL processed = NO;
    
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
    else if (event.type == NSEventTypeLeftMouseDragged)
    {
        NSPoint point = [self.openGLView convertPoint:[event locationInWindow] fromView:nil];
        
        if ([self.openGLView hitTest:point])
        {
            
        }
    }
    
    return processed;
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
