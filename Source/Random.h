//
//  Random.h
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Random : NSObject

+ (NSInteger)randomIntegerFromMin:(NSInteger)min toMax:(NSInteger)max;

+ (NSString *)randomGeneSequenceWithLength:(NSUInteger)length domain:(NSString *)domain;

@end
