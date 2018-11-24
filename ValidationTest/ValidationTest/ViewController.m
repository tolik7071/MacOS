//
//  ViewController.m
//  ValidationTest
//
//  Created by tolik7071 on 11/24/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, getter = isUserDataValid) BOOL userDataValid;
@property (nonatomic) NSString * firstNameValue;
@property (nonatomic) NSString * lastNameValue;
@property (nonatomic) NSString * emailValue;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)close:(id)sender
{
    [self.view.window performClose:self];
}

- (IBAction)sendData:(id)sender
{
//    [[self class] endEditingForViews:self.view.subviews];
//
//    if ([self isUserDataValid])
//    {
//        NSLog(@"%s", __PRETTY_FUNCTION__);
//        [self.view.window performClose:self];
//    }
    
    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = self;
    [popover setContentSize:NSMakeSize(200.0, 100.0)];
    [popover setBehavior:NSPopoverBehaviorTransient];
    [popover setAnimates:YES];
    
    NSRect relativeRect = [self.firstName convertRect:self.firstName.bounds toView:self.view];
    [popover showRelativeToRect:relativeRect ofView:self.firstName preferredEdge:NSMinYEdge];
}

- (BOOL)isUserDataValid
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return (self.firstNameValue.length > 0 && self.lastNameValue.length > 0 && [self isEmailValid]);
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingUserDataValid
{
    return [NSSet setWithObjects:@"firstNameValue", @"lastNameValue", @"emailValue", nil];
}

- (BOOL)isEmailValid
{
    //RFC 2822
    NSString *localPart = @"(?:[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")";
    NSString *domainPart = @"@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSString *emailRegex = [NSString stringWithFormat:@"%@%@", localPart, domainPart];
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isEmailValid = [emailTest evaluateWithObject:self.emailValue];
    
    return isEmailValid;
}

+ (BOOL)endEditingForViews:(NSArray <NSView * > *)views
{
    BOOL isDone = NO;
    
    for (NSView *view in views)
    {
        if ([view isKindOfClass:[NSControl class]])
        {
            NSText *editor = [(NSControl*)view currentEditor];
            if (editor)
            {
                [(NSControl *)view endEditing:editor];
                isDone = YES;
                break;
            }
        }
        else
        {
            isDone = [self endEditingForViews:view.subviews];
            if (isDone)
            {
                break;
            }
        }
    }
    
    return isDone;
}

#pragma mark - NSControlSubclassNotifications

- (void)controlTextDidChange:(NSNotification *)obj
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self willChangeValueForKey:@"userDataValid"];
    [self didChangeValueForKey:@"userDataValid"];
}

@end
