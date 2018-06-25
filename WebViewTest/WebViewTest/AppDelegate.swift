//
//  AppDelegate.swift
//  WebViewTest
//
//  Created by Anatoliy Goodz on 6/15/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

   func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
      return true;
   }

}

