
//  FilenameValueTransformer.m

//  Created by Sebastian Jachec on 31/03/2015.
//  Copyright (c) 2015 Sebastian Jachec. All rights reserved.

#import "FilenameValueTransformer.h"

@implementation FilenameValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(NSString*)value {
    if (value) {
        NSString *filterChars = [NSUserDefaults.standardUserDefaults stringForKey:@"filterChars"];
        
        NSMutableString *shortened = value.lastPathComponent.stringByDeletingPathExtension.mutableCopy;
        
        if (filterChars) {
            for (int i = 0; i < filterChars.length; i++) {
                NSString *toReplace = [filterChars substringWithRange:NSMakeRange(i, 1)];
                [shortened replaceOccurrencesOfString:toReplace withString:@" " options:0 range:NSMakeRange(0,shortened.length)];
            }
        }
        
        if ([NSUserDefaults.standardUserDefaults boolForKey:@"capitalizeNames"]) return shortened.capitalizedString;
        
        return shortened.copy;
    }
    return value;
}

@end
