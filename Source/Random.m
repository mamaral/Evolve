//
//  Random.m
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "Random.h"

@implementation Random

+ (NSInteger)randomIntegerFromMin:(NSInteger)min toMax:(NSInteger)max {
    return (min + arc4random_uniform((u_int32_t)max - (u_int32_t)min + 1));
}

+ (NSString *)randomGeneSequenceWithLength:(NSUInteger)length domain:(NSString *)domain {
    NSParameterAssert(length > 0);
    NSParameterAssert(domain);
    NSParameterAssert(domain.length > 0);

    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];

    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [domain characterAtIndex:[[self class] randomIntegerFromMin:0 toMax:domain.length - 1]]];
    }

    return randomString;
}

@end
