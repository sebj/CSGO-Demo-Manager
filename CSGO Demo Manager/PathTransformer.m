
//  PathTransformer.m

//  Created by Sebastian Jachec on 06/04/2015.
//  Copyright (c) 2015 Sebastian Jachec. All rights reserved.

#import "PathTransformer.h"

@implementation PathTransformer

+ (Class)transformedValueClass {
    return [NSURL class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)reverseTransformedValue:(NSURL*)value {
    return value? value.path : value;
}

- (id)transformedValue:(NSString*)value {
    return value? [NSURL fileURLWithPath:value] : value;
}

@end
