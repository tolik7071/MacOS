//
//  AppDelegate.m
//  AutoLayoutTest
//
//  Created by Anatoliy Goodz on 2/3/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import "AppDelegate.h"

const char * GetLayoutAttributeName(NSLayoutAttribute attribute)
{
    return attribute == NSLayoutAttributeLeft ? "NSLayoutAttributeLeft" :
        attribute == NSLayoutAttributeRight ? "NSLayoutAttributeRight" :
        attribute == NSLayoutAttributeTop ? "NSLayoutAttributeTop" :
        attribute == NSLayoutAttributeBottom ? "NSLayoutAttributeBottom" :
        attribute == NSLayoutAttributeLeading ? "NSLayoutAttributeLeading" :
        attribute == NSLayoutAttributeTrailing ? "NSLayoutAttributeTrailing" :
        attribute == NSLayoutAttributeWidth ? "NSLayoutAttributeWidth" :
        attribute == NSLayoutAttributeHeight ? "NSLayoutAttributeHeight" :
        attribute == NSLayoutAttributeCenterX ? "NSLayoutAttributeCenterX" :
        attribute == NSLayoutAttributeCenterY ? "NSLayoutAttributeCenterY" :
        attribute == NSLayoutAttributeBaseline ? "NSLayoutAttributeBaseline" :
        attribute == NSLayoutAttributeLastBaseline ? "NSLayoutAttributeLastBaseline" :
        attribute == NSLayoutAttributeBaseline ? "NSLayoutAttributeBaseline" : "NSLayoutAttributeFirstBaseline";
}

const char * GetLayoutRelationName(NSLayoutRelation relation)
{
    return relation == NSLayoutRelationLessThanOrEqual ? "NSLayoutRelationLessThanOrEqual" :
        relation == NSLayoutRelationEqual ? "NSLayoutRelationEqual" : "NSLayoutRelationGreaterThanOrEqual";
}

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow* window;
@property (weak) IBOutlet NSTextField* field1;
@property (weak) IBOutlet NSTextField* field2;
@property (weak) IBOutlet NSTextField* field3;
@property (weak) IBOutlet NSTextField* field4;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)hideTextField:(id)sender
{
    BOOL currentState = self.field3.hidden;
    self.field3.hidden = !currentState;
    
    [self fixAutoLayut];
}

- (void)fixAutoLayut
{
    printf("%s\n", [[self.field3 description] UTF8String]);
    
    NSArray<NSLayoutConstraint *> *constraints = [self.field3
        constraintsAffectingLayoutForOrientation:NSLayoutConstraintOrientationVertical];
    for (NSLayoutConstraint *constraint in constraints)
    {
        printf("%s `%s` %s %s `%s' * %.2f + %.2f\n"
               , [[[constraint firstItem] description] UTF8String]
               , GetLayoutAttributeName([constraint firstAttribute])
               , GetLayoutRelationName([constraint relation])
               , [[[constraint secondItem] description] UTF8String]
               , GetLayoutAttributeName([constraint secondAttribute])
               , [constraint multiplier]
               , [constraint constant]);
    }
    
    if (! self.field3.hidden)
    {
        
    }
    else
    {
        
    }
}

@end
