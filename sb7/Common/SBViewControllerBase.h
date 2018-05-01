//
//  SBViewControllerBase.h
//  OpenGL SB Tests
//
//  Created by tolik7071 on 4/3/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyTimeStamp.h"

@interface SBViewControllerBase : NSViewController
{
   @protected
   id                  _monitor;
   CVDisplayLinkRef    _displayLink;
   GLfloat             _deltaTime;
   GLfloat             _lastFrame;
}

@property (nonatomic, weak) IBOutlet NSOpenGLView * openGLView;

- (void)cleanup;
- (void)configOpenGLView;
- (void)configDisplayLink;

// Must be implemented in child class
- (void)configOpenGLEnvironment;
- (void)renderForTime:(MyTimeStamp *)time;

@end
