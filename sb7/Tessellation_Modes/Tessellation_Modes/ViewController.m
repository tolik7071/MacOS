//
//  ViewController.m
//  Tessellation_Modes
//
//  Created by tolik7071 on 4/4/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#import "GLUtilities.h"

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

typedef NS_ENUM(NSUInteger, TessellationModes)
{
    kQuads          = 0,
    kTriangles		= 1,
    kQuadsAsPoints	= 2,
    kIsolines		= 3
};

@interface ViewController ()

@property TessellationModes tessellationMode;

@end

@implementation ViewController
{
    id                  _monitor;
    CVDisplayLinkRef    _displayLink;
    GLfloat             _deltaTime;
    GLfloat             _lastFrame;
    GLuint              _programIDs[4];
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
    
    for (int i = 0; i < sizeof(_programIDs); i++)
    {
        if (0 != _programIDs[i])
        {
            glDeleteProgram(_programIDs[i]);
        }
    }
    
    if (0 != _VAO)
    {
        glDeleteVertexArrays(1, &_VAO);
    }
}

- (IBAction)selectMode:(id)sender
{
    self.tessellationMode = (TessellationModes)[sender tag];
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
    
    static NSArray<NSString * > *vertexSources;
    static dispatch_once_t runOnceVertex;
    dispatch_once(&runOnceVertex, ^{
        vertexSources = @[@"quad.vert", @"quad.vert", @"quad.vert", @"quad.vert"];
    });
    
    static NSArray<NSString * > *fragmentSources;
    static dispatch_once_t runOnceFragment;
    dispatch_once(&runOnceFragment, ^{
        fragmentSources = @[@"quad.frag", @"quad.frag", @"quad.frag", @"quad.frag"];
    });
    
    static NSArray<NSString * > *tessellationControlSources;
    static dispatch_once_t runOnceTessellationControl;
    dispatch_once(&runOnceTessellationControl, ^{
        tessellationControlSources = @[@"quads.tesc", @"triangles.tesc", @"triangles.tesc", @"isolines.tesc"];
    });
    
    static NSArray<NSString * > *tessellationEvaluationSources;
    static dispatch_once_t runOnceTessellationEvaluation;
    dispatch_once(&runOnceTessellationEvaluation, ^{
        tessellationEvaluationSources = @[@"quads.tese", @"triangles.tese", @"triangles_as_points.tese", @"isolines.tese"];
    });
    
    for (int i = 0; i < 4; i++)
    {
        NSURL *vertexShader = FindResourceWithName(vertexSources[i]);
        NSAssert(vertexShader, @"Cannot find shader.");
        NSData *vertexShaderContent = ReadFile(vertexShader);
        NSAssert([vertexShaderContent length] > 0, @"Empty shader.");
        
        NSURL *fragmentShader = FindResourceWithName(fragmentSources[i]);
        NSAssert(fragmentShader, @"Cannot find shader.");
        NSData *fragmentShaderContent = ReadFile(fragmentShader);
        NSAssert([fragmentShaderContent length] > 0, @"Empty shader.");
        
        NSURL *tessellationControlShader = FindResourceWithName(tessellationControlSources[i]);
        NSAssert(tessellationControlShader, @"Cannot find shader.");
        NSData *tessellationControlShaderContent = ReadFile(tessellationControlShader);
        NSAssert([tessellationControlShaderContent length] > 0, @"Empty shader.");
        
        NSURL *tessellationEvaluationShader = FindResourceWithName(tessellationEvaluationSources[i]);
        NSAssert(tessellationEvaluationShader, @"Cannot find shader.");
        NSData *tessellationEvaluationShaderContent = ReadFile(tessellationEvaluationShader);
        NSAssert([tessellationEvaluationShaderContent length] > 0, @"Empty shader.");
        
        _programIDs[i] = CreateProgram2(
            vertexShaderContent,
            tessellationControlShaderContent,
            tessellationEvaluationShaderContent,
            fragmentShaderContent);
        NSAssert(_programIDs[i] != 0, @"Cannot compile program.");
    }
    
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
    
    const GLfloat backgroundColor[] = { 0.2f, 0.2f, 0.2f, 1.0f };
    glClearBufferfv(GL_COLOR, 0, backgroundColor);
    
    [self.openGLView.openGLContext flushBuffer];
}

- (void)setupControls
{
    for (NSButton *button in self.stackView.views)
    {
        NSMutableAttributedString *attributes = [[NSMutableAttributedString alloc]
            initWithAttributedString:[button attributedTitle]];
        [attributes addAttribute:NSForegroundColorAttributeName value:[NSColor redColor]
            range:NSMakeRange(0, [attributes length])];
        [button setAttributedTitle:attributes];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupControls];
    
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
