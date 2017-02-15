//
//  AppDelegate.m
//  WindowStyleIssue
//
//  Created by Anatoliy Goodz on 3/5/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "AppDelegate.h"
#import "TestWindowController.h"

@interface AppDelegate ()
{
    TestWindowController*    _windowController;
}

@property (assign) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    [_windowController close:nil];
    [_windowController release];
}

- (TestWindowController*)windowController {
    
    if (! _windowController)
    {
        _windowController = [[TestWindowController alloc]
            initWithWindowNibName:@"TestWindowController"];
    }
    
    return _windowController;
}

#define USE_OPEN_PANEL

- (IBAction)showDiaolg:(id)aSender {

#if !defined(USE_OPEN_PANEL)
    NSWindow *dialog = [[self windowController] window];
    
//#define APPLY_FIX
#if defined(APPLY_FIX)
        NSUInteger styleMask = [dialog styleMask];
        styleMask &= ~0x40;
        [dialog setStyleMask:styleMask];
#endif // APPLY_FIX
    
    [NSApp runModalForWindow:dialog];
#else
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel runModal];
#endif // !USE_OPEN_PANEL
}

- (IBAction)showSheet:(id)aSender {

#if !defined(USE_OPEN_PANEL)
    NSWindow *sheet = [[self windowController] window];

//#define USE_NEW_STYLE_API
#if !defined(USE_NEW_STYLE_API)
    [NSApp beginSheet:sheet
       modalForWindow:self.window
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
#else
    [self.window beginSheet:sheet
        completionHandler:^(NSModalResponse returnCode) {
        
        }];
#endif
#else
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [self.window beginSheet:panel completionHandler:^(NSModalResponse returnCode) {
        
    }];
#endif // !USE_OPEN_PANEL
}

@end
