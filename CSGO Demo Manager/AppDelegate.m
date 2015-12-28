//
//  AppDelegate.m
//  CS:GO Demo Manager
//
//  Created by Sebastian Jachec on 04/04/2015.
//  Copyright (c) 2015 Sebastian Jachec. All rights reserved.
//

#import "AppDelegate.h"
#import "AppController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [NSUserDefaults.standardUserDefaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"ud" ofType:@"plist"]]];
    
    [self.appController setup];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.appController tidy];
}

@end
