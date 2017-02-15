//
//  AppDelegate.m
//  SaveAsTest
//
//  Created by Anatoliy Goodz on 6/23/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void) printMenu:(NSMenu *)aMenu
{
    for (NSMenuItem *item in [aMenu itemArray])
    {
        [self printMenuItem:item];        
    }
}

- (void) printMenuItem:(NSMenuItem *)anItem
{
    for (int i = 0; i < self.tabs; ++i)
    {
        printf("\t");
    }
    
    printf("%s"
           , [[anItem title] length] > 0
           ? [[anItem title] UTF8String]
           : "------");
    if (anItem.keyEquivalent.length > 0)
    {
        printf("\t(");
        if ((anItem.keyEquivalentModifierMask & NSShiftKeyMask) != 0)
        {
            printf("SHIFT ");
        }
        if ((anItem.keyEquivalentModifierMask & NSAlternateKeyMask) != 0)
        {
            printf("ALT ");
        }
        if ((anItem.keyEquivalentModifierMask & NSCommandKeyMask) != 0)
        {
            printf("CMD ");
        }
        if ((anItem.keyEquivalentModifierMask & NSControlKeyMask) != 0)
        {
            printf("CTRL ");
        }
        printf("%s), tag = %ld", [anItem.keyEquivalent UTF8String], anItem.tag);
    }
    printf("\n");
    
    for (NSMenuItem *item in [[anItem submenu] itemArray])
    {
        self.tabs++;
        [self printMenuItem:item];
        self.tabs--;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self printMenu:[NSApp mainMenu]];
    
    NSMenu *submenuForSaveAs = [[NSMenu alloc] init];
    
    NSMenuItem *saveOnLocalFSMenuItem = [[NSMenuItem alloc]
        initWithTitle:@"Save on the local file system…"
        action:@selector(saveInLocalFS:)
        keyEquivalent:@"S"];
    [submenuForSaveAs insertItem:saveOnLocalFSMenuItem atIndex:0];
    
    NSMenuItem *saveOnDropboxMenuItem = [[NSMenuItem alloc]
        initWithTitle:@"Save on the dropbox disk…"
        action:@selector(saveInDropBox:)
        keyEquivalent:@"D"];
    [submenuForSaveAs insertItem:saveOnDropboxMenuItem atIndex:1];
    
    NSMenuItem *fileMenuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
    NSMenuItem *saveAsMenuItem = [[fileMenuItem submenu] itemWithTitle:@"Save As…"];
    saveAsMenuItem.title = @"Save As";
    saveAsMenuItem.keyEquivalent = @"";
    
    saveAsMenuItem.submenu = submenuForSaveAs;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)aSender
{
    return YES;
}

- (IBAction)saveDocumentAs:(id)aSender
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [aSender description]);
}

- (void) saveInLocalFS:(id)aSender
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [aSender description]);
}

- (void) saveInDropBox:(id)aSender
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [aSender description]);
}

@end
