//
//  Organism.h
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Genome.h"

@interface Organism : NSObject

@property (nonatomic, strong) Genome *genome;

@property (nonatomic) NSInteger fitness;

- (instancetype)initWithGenome:(Genome *)genome;
- (instancetype)initRandomWithGeneSequenceLength:(NSUInteger)length domain:(NSString *)domain;

+ (instancetype)offspringFromParent1:(Organism *)parent1 parent2:(Organism *)parent2 mutationRate:(CGFloat)mutationRate;

@end
