//
//  ViewController.h
//  Tessellation_Modes
//
//  Created by tolik7071 on 4/4/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSOpenGLView * openGLView;
@property (nonatomic, weak) IBOutlet NSStackView * stackView;

- (IBAction)selectMode:(id)sender;

@end

