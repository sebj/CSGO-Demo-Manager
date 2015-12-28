
//  ManualSharingService.m

//  Created by Sebastian Jachec on 07/04/2015.
//  Copyright (c) 2015 Sebastian Jachec. All rights reserved.

#import "ManualSharingService.h"

@interface ManualSharingService () {
    NSSharingService *realService;
}

@end

@implementation ManualSharingService

+ (instancetype)service {
    static ManualSharingService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [ManualSharingService new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        realService = [[NSSharingService alloc] initWithTitle:@"Manual" image:nil alternateImage:nil handler:^(void){
        }];
        realService.delegate = self;
    }
    return self;
}

- (void)sharingService:(NSSharingService *)sharingService didFailToShareItems:(NSArray *)items error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sharingService:didFailToShareItems:error:)]) {
        [self.delegate sharingService:realService didFailToShareItems:items error:error];
    }
}

- (void)sharingService:(NSSharingService *)sharingService didShareItems:(NSArray *)items {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sharingService:didShareItems:)]) {
        [self.delegate sharingService:realService didShareItems:items];
    }
}

- (BOOL)canPerformWithItems:(NSArray *)items {
    //Initialise, if not already
    [ManualSharingService service];
    
    return [realService canPerformWithItems:items];
}

- (void)performWithItems:(NSArray *)items {
    if (items.count > 0)
        [NSWorkspace.sharedWorkspace activateFileViewerSelectingURLs:items];
}

@end
