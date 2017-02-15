//
//  AppDelegate.h
//  ComboboxText
//
//  Created by Anatoliy Goodz on 9/30/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate
    , NSComboBoxDataSource
    , NSComboBoxCellDataSource>

@property (assign) IBOutlet NSComboBox *combobox;

@end

