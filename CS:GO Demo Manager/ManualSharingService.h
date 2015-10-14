
//  ManualSharingService.h

//  Created by Sebastian Jachec on 07/04/2015.
//  Copyright (c) 2015 Sebastian Jachec. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface ManualSharingService : NSSharingService <NSSharingServiceDelegate>

+ (instancetype)service;

@end
