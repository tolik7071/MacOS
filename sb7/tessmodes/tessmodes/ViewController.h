//
//  ViewController.h
//  tessmodes
//
//  Created by tolik7071 on 1/26/19.
//  Copyright © 2019 tolik7071. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBViewControllerBase.h"

@interface ViewController : SBViewControllerBase

@property (nonatomic, weak) IBOutlet NSStackView * stackView;

- (IBAction)selectMode:(id)sender;

@end

