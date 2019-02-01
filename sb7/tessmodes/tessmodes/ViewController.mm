//
//  ViewController.m
//  tessmodes
//
//  Created by tolik7071 on 1/26/19.
//  Copyright © 2019 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>

#define NUMBER_OF_PROGRAMS 4

typedef NS_ENUM(NSUInteger, TessellationModes)
{
    kQuads            = 0,
    kTriangles        = 1,
    kQuadsAsPoints    = 2,
    kIsolines         = 3
};

@interface ViewController ()

@property TessellationModes tessellationMode;

@end

@implementation ViewController
{
    GLuint          _programIDs[NUMBER_OF_PROGRAMS];
    GLuint          _VAO;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _VAO)
    {
        glDeleteVertexArrays(1, &_VAO);
        _VAO = 0;
    }
    
    for (int i = 0; i < NUMBER_OF_PROGRAMS; i++)
    {
        if (0 != _programIDs[i])
        {
            glDeleteProgram(_programIDs[i]);
        }
    }
}

- (void)configOpenGLView
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
        NSOpenGLPFAOpenGLProfile        , NSOpenGLProfileVersion4_1Core,
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

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    static NSArray<NSString * > *vertexSources;
    static NSArray<NSString * > *fragmentSources;
    static NSArray<NSString * > *tessellationControlSources;
    static NSArray<NSString * > *tessellationEvaluationSources;
    
    static dispatch_once_t runOnce;
    dispatch_once(&runOnce, ^{
        vertexSources = @[@"quad.vert", @"quad.vert", @"quad.vert", @"quad.vert"];
        fragmentSources = @[@"quad.frag", @"quad.frag", @"quad.frag", @"quad.frag"];
        tessellationControlSources = @[@"quads.tesc", @"triangles.tesc", @"triangles.tesc", @"isolines.tesc"];
        tessellationEvaluationSources = @[@"quads.tese", @"triangles.tese", @"triangles_as_points.tese", @"isolines.tese"];
    });
    
    for (int i = 0; i < NUMBER_OF_PROGRAMS; i++)
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
    
    glPatchParameteri(GL_PATCH_VERTICES, 4);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    const GLfloat backgroundColor[] = { 0.2f, 0.2f, 0.2f, 1.0f };
    glClearBufferfv(GL_COLOR, 0, backgroundColor);
    
    glUseProgram(_programIDs[self.tessellationMode]);
    
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glDrawArrays(GL_PATCHES, 0, 4);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    
    [self.openGLView.openGLContext flushBuffer];
}

- (IBAction)selectMode:(id)sender
{
    self.tessellationMode = (TessellationModes)[sender tag];
}

@end
