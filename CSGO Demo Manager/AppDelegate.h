//
//  AppDelegate.h
//  CS:GO Demo Manager
//
//  Created by Sebastian Jachec on 04/04/2015.
//  Copyright (c) 2015 Sebastian Jachec. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) IBOutlet AppController *appController;

@end

