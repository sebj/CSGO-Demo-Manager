
//  AppController.h
//  CS:GO Demo Manager

//  Created by Sebastian Jachec on 04/04/2015.
//  Copyright (c) 2015 Sebastian Jachec. All rights reserved.

#import <Cocoa/Cocoa.h>

@class TableView, FilenameValueTransformer;

@interface AppController : NSObject <NSSharingServiceDelegate> {
    BOOL justLaunched;
    
    NSString *demoFolderPath;
    
    FilenameValueTransformer *filenameValueTransformer;
    
    NSViewController *popoverViewController;
    NSPopover *popover;
    
    NSMutableDictionary *zipPaths;
    NSMutableDictionary *zipOwners;
}

@property (strong) NSArray *demos;
@property (strong) IBOutlet NSArrayController *arrayController;

@property (strong) NSArray *sortDescriptors;

@property (strong) IBOutlet NSWindow *mainWindow;
@property (strong) IBOutlet NSWindow *prefsWindow;

@property (strong) IBOutlet TableView *tableView;

@property (strong) IBOutlet NSMenuItem *demoMenu;
@property (strong) IBOutlet NSMenuItem *shareMenuItem;
@property (strong) IBOutlet NSMenuItem *rightClickShareMenuItem;

@property (strong) IBOutlet NSMenuItem *sortByFileNameMenuItem;
@property (strong) IBOutlet NSMenuItem *sortByMapNameMenuItem;

@property (strong) IBOutlet NSView *popoverView;

- (void)setup;
- (void)tidy;

- (IBAction)refresh:(id)sender;

- (IBAction)sortByFileName:(NSMenuItem*)sender;
- (IBAction)sortByMapName:(NSMenuItem*)sender;

- (IBAction)showInfo:(id)sender;

- (IBAction)openFolder:(id)sender;
- (IBAction)playDemo:(id)sender;

@end
