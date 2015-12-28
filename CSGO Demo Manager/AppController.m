
//  AppController.m
//  CS:GO Demo Manager

//  Created by Sebastian Jachec on 04/04/2015.
//  Copyright (c) 2015 Sebastian Jachec. All rights reserved.

#import "AppController.h"
#import "SJSourceDemo.h"
#import "TableView.h"
#import "FilenameValueTransformer.h"
#import "WAYTheDarkSide.h"
#import "NSSharingServicePicker+ESSSharingServicePickerMenu.h"
#import "ManualSharingService.h"
#import "SSZipArchive.h"

@implementation AppController

- (void)setup {
    [WAYTheDarkSide welcomeApplicationWithBlock:^{
        NSAppearance *a = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        [self.mainWindow setAppearance:a];
        popover.appearance = a;
    } immediately:YES];
    
    [WAYTheDarkSide outcastApplicationWithBlock:^{
        NSAppearance *a = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        [self.mainWindow setAppearance:a];
        popover.appearance = a;
    } immediately:YES];
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"mapName" ascending:YES comparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 localizedCaseInsensitiveCompare:obj2];
    }];
    
    _sortDescriptors = @[sorter];
    
    zipPaths = [NSMutableDictionary new];
    zipOwners = [NSMutableDictionary new];
    
    self.tableView.doubleAction = @selector(doubleClick);
    self.tableView.target = self;
    
    justLaunched = YES;
    
    [self refresh:nil];
    
    [self tableView:self.tableView shouldSelectRow:-1];
}

- (void)tidy {
    for (NSString *key in zipOwners)
        [NSFileManager.defaultManager removeItemAtPath:key error:NULL];
}

- (BOOL)loadDemos {
    BOOL allGood = YES;
    demoFolderPath = [NSUserDefaults.standardUserDefaults stringForKey:@"folderPath"];
    
    if (!demoFolderPath || demoFolderPath.length == 0) {
        NSString *defaultReplaysPath = @"~/Library/Application Support/Steam/steamapps/common/Counter-Strike Global Offensive/csgo/replays".stringByExpandingTildeInPath;
        
        [NSUserDefaults.standardUserDefaults setValue:defaultReplaysPath forKey:@"folderPath"];
        demoFolderPath = defaultReplaysPath;
        
        if (![NSFileManager.defaultManager fileExistsAtPath:defaultReplaysPath]) {
            allGood = NO;
            [self.prefsWindow makeKeyAndOrderFront:nil];
            
            NSAlert *alert = [NSAlert new];
            alert.alertStyle = NSInformationalAlertStyle;
            alert.messageText = @"No demos folder chosen.";
            alert.informativeText = @"Please choose a folder containing demo (.dem) files.";
            alert.icon = [NSImage imageNamed:NSImageNameCaution];
            [alert addButtonWithTitle:@"OK"];
            [alert beginSheetModalForWindow:self.prefsWindow completionHandler:^(NSModalResponse returnCode) {}];
            return allGood;
        }
    }
    
    NSDirectoryEnumerator *enumerator = [NSFileManager.defaultManager enumeratorAtURL:[NSURL fileURLWithPath:demoFolderPath.stringByExpandingTildeInPath isDirectory:YES] includingPropertiesForKeys:@[] options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:^(NSURL *u, NSError *e) {
        return YES; //Continue after error
    }];
    
    for (NSURL *url in enumerator) {
        if ([url.pathExtension.lowercaseString isEqualToString:@"dem"]) {
            SJSourceDemo *demo = [[SJSourceDemo alloc] initWithContentsOfURL:url];
            [self.arrayController addObject:demo];
        }
    }
    
    return allGood;
}

- (IBAction)refresh:(id)sender {
    self.demos = @[];
    BOOL loaded = [self loadDemos];
    
    if (justLaunched && loaded) {
        [self.mainWindow makeKeyAndOrderFront:nil];
        justLaunched = NO;
    }
    
    [self updateSharingMenu];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    BOOL validRow = (row != -1);
    self.demoMenu.enabled = validRow;
    return YES;
}

- (long)clickedTableRow {
    long idx = self.tableView.clickedRow;
    
    if (idx == -1) return self.tableView.selectedRow;
    
    return idx;
}

#pragma mark - Popover

- (void)setupPopoverComponents {
    filenameValueTransformer = [FilenameValueTransformer new];
    
    popoverViewController = [NSViewController new];
    popoverViewController.view = self.popoverView;
    
    popover = [NSPopover new];
    popover.animates = YES;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentViewController = popoverViewController;
}

+ (NSDateFormatter *)cachedDateFormatter {
    NSMutableDictionary *threadDictionary = NSThread.currentThread.threadDictionary;
    NSDateFormatter *dateFormatter = [threadDictionary objectForKey:@"cachedDateFormatter"];
    if (dateFormatter == nil) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.locale = NSLocale.currentLocale;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
        [threadDictionary setObject:dateFormatter forKey:@"cachedDateFormatter"];
    }
    return dateFormatter;
}

//Small utility method to shorten code in doubleClick
- (NSTextField*)popoverViewWithTag:(NSInteger)t {
    return (NSTextField*)[self.popoverView viewWithTag:t];
}

- (void)doubleClick {
    if (!popover) [self setupPopoverComponents];
    
    NSInteger i = self.clickedTableRow;
    if (i == -1) i = self.tableView.selectedRow;
    
    if (i != -1) {
        SJSourceDemo *demo = self.arrayController.arrangedObjects[i];
        //Name
        [self popoverViewWithTag:1].stringValue = [filenameValueTransformer transformedValue:demo.filePath];
        //Creation date
        [self popoverViewWithTag:2].stringValue = [AppController.cachedDateFormatter stringFromDate:demo.creationDate];
        //Map
        [self popoverViewWithTag:4].stringValue = demo.mapName;
        //Server
        [self popoverViewWithTag:5].stringValue = demo.server;
        
        //3 = Type
        //6 = "Player:"
        //7 = Player name
        if (demo.demoType == DemoTypePOV) {
            [self.popoverView setFrameSize:NSMakeSize(self.popoverView.frame.size.width, 178)];
            [self popoverViewWithTag:3].stringValue = @"POV";
            [self popoverViewWithTag:6].hidden = NO;
            [self popoverViewWithTag:7].hidden = NO;
            [self popoverViewWithTag:7].stringValue = demo.playerName;
        } else {
            [self.popoverView setFrameSize:NSMakeSize(self.popoverView.frame.size.width, 152)];
            [self popoverViewWithTag:3].stringValue = @"GOTV";
            [self popoverViewWithTag:6].hidden = YES;
            [self popoverViewWithTag:7].hidden = YES;
        }
        
        [popover showRelativeToRect:[self.tableView rectOfRow:i] ofView:self.tableView preferredEdge:NSMaxXEdge];
    }
}

#pragma mark - Array Sorting

- (void)sortArrayControllerWithKey:(NSString*)k {
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:k ascending:YES comparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 localizedCaseInsensitiveCompare:obj2];
    }];
    
    _arrayController.sortDescriptors = @[sorter];
}

- (IBAction)sortByFileName:(NSMenuItem*)sender {
    [self sortArrayControllerWithKey:@"filePath"];
    
    sender.state = NSOnState;
    _sortByMapNameMenuItem.state = NSOffState;
}

- (IBAction)sortByMapName:(NSMenuItem*)sender {
    [self sortArrayControllerWithKey:@"mapName"];
    
    sender.state = NSOnState;
    _sortByFileNameMenuItem.state = NSOffState;
}

#pragma mark -

- (IBAction)openFolder:(id)sender {
    [NSWorkspace.sharedWorkspace openFile:demoFolderPath withApplication:@"Finder"];
}

- (NSString*)encodeToPercentEscapeString:(NSString *)string {
    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"]];
}

- (IBAction)showInfo:(id)sender {
    [self doubleClick];
}

- (IBAction)playDemo:(NSMenuItem*)sender {
    //steam://run/730//
    //Followed by URL encoded form of: "+playdemo relativePath/toFile.dem"
    BOOL CSGOExists = [NSFileManager.defaultManager fileExistsAtPath:@"~/Library/Application Support/Steam/steamapps/common/Counter-Strike Global Offensive/csgo_osx".stringByExpandingTildeInPath];
    
    BOOL UserSteamExists = [NSFileManager.defaultManager fileExistsAtPath:@"~/Applications/Steam.app".stringByExpandingTildeInPath];
    BOOL AppSteamExists = [NSFileManager.defaultManager fileExistsAtPath:@"/Applications/Steam.app"];
    
    if (CSGOExists && (UserSteamExists || AppSteamExists)) {
        
        long idx = [sender.menu.title isEqualToString:@"Demo"]? self.clickedTableRow : self.tableView.rightClickedRow;
        
        NSString *opts = [self encodeToPercentEscapeString:[self.demos[idx] playDemoLaunchOptions]];
        [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[@"steam://run/730//%@" stringByAppendingString:opts]]];
        
    } else {
        NSBeep();
    }
}

- (IBAction)revealDemoInFinder:(NSMenuItem*)sender {
    NSURL *url;
    if ([sender.menu.title isEqualToString:@"Demo"]) {
        url = [self.demos[self.clickedTableRow] fileURL];
        
    } else {
        url = [self.demos[self.tableView.rightClickedRow] fileURL];
    }
    
    [NSWorkspace.sharedWorkspace activateFileViewerSelectingURLs:@[url]];
}

- (IBAction)delete:(NSMenuItem*)sender {
    long idx = [sender.menu.title isEqualToString:@"Demo"]? self.clickedTableRow : self.tableView.rightClickedRow;
    
    NSAlert *alert = [NSAlert new];
    alert.alertStyle = NSInformationalAlertStyle;
    alert.messageText = [NSString stringWithFormat:@"Are you sure you want to delete \"%@\"?",[self.demos[idx] filePath].lastPathComponent];
    alert.informativeText = @"This demo will be deleted immediately.";
    alert.icon = [NSImage imageNamed:NSImageNameCaution];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert beginSheetModalForWindow:self.mainWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            
            NSError *err;
            [NSFileManager.defaultManager trashItemAtURL:[self.demos[idx] fileURL] resultingItemURL:nil error:&err];
            if (!err) {
                
                NSSound *systemSound = [[NSSound alloc] initWithContentsOfFile:@"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" byReference:YES];
                if (systemSound) [systemSound play];
                
                [self refresh:nil];
            }
        }
    }];
}

#pragma mark - Sharing

- (void)updateSharingMenu {
    if (self.demos.count > 0) {
        NSMenu *sharingMenu = [NSSharingServicePicker menuForSharingItems:@[[self.demos[0] fileURL]] withTarget:self selector:@selector(share:) serviceDelegate:self];
        
        NSSharingService *service = [ManualSharingService service];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Manually" action:@selector(share:) keyEquivalent:@""];
        item.representedObject = service;
        service.delegate = self;
        item.target = self;
        [sharingMenu addItem:item];
        
        self.shareMenuItem.submenu = sharingMenu;
        self.rightClickShareMenuItem.submenu = sharingMenu.copy;
    }
}

- (void)share:(NSMenuItem *)item {
    SJSourceDemo *demo;
    
    if ([item.menu.supermenu.title isEqualToString:@"Demo"]) {
        demo = self.arrayController.arrangedObjects[self.clickedTableRow];
        
    } else {
        demo = self.arrayController.arrangedObjects[self.tableView.rightClickedRow];
    }
    
    NSString *zippedPath = [zipPaths valueForKey:demo.filePath];
    BOOL zipped = NO;
    if (zippedPath) {
        zipped = YES;
        
    } else {
        zippedPath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.zip",demo.filePath.lastPathComponent.stringByDeletingPathExtension];
        
        zipped = [SSZipArchive createZipFileAtPath:zippedPath withFilesAtPaths:@[demo.filePath]];
    }
    
    if (zipped) {
        [zipPaths setValue:zippedPath forKey:demo.filePath];
        
        NSNumber *num = [zipOwners objectForKey:zippedPath];
        [zipOwners setObject:(num? @(num.intValue+1) : @1) forKey:zippedPath];
        
        NSURL *zip = [NSURL fileURLWithPath:zippedPath];
        
        NSSharingService *service = item.representedObject;
        service.delegate = self;
        [service performWithItems:@[zip]];
        
    } else {
        NSBeep();
    }
}

- (void)sharingService:(NSSharingService *)sharingService didFailToShareItems:(NSArray *)items error:(NSError *)error {
    [self tidySharedItems:items];
}
- (void)sharingService:(NSSharingService *)sharingService didShareItems:(NSArray *)items {
    [self tidySharedItems:items];
}

- (void)tidySharedItems:(NSArray*)items {
    NSItemProvider *itemProvider = items[0];
    
    if (itemProvider && [itemProvider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeURL]) {
        [itemProvider loadItemForTypeIdentifier:(NSString*)kUTTypeURL options:nil completionHandler:^(NSURL *u, NSError *err) {
            if (!err) {
                NSNumber *num = [zipOwners objectForKey:u.path];
                if (num.intValue == 1) [NSFileManager.defaultManager removeItemAtURL:u error:nil];
                
                int newValue = num.intValue-1;
                if (newValue == 0) {
                    [zipOwners removeObjectForKey:u.path];
                } else {
                    [zipOwners setObject:@(newValue) forKey:u.path];
                }
            }
        }];
    }
}

@end
