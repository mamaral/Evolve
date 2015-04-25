//
//  Organism.h
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Genome.h"

typedef NS_ENUM(NSUInteger, CrossoverMethod) {
    CrossoverMethodOnePoint,
    CrossoverMethodTwoPoint
};

@interface Organism : NSObject

@property (nonatomic, strong) Genome *genome;

@property (nonatomic) NSInteger fitness;

- (instancetype)initWithGenome:(Genome *)genome;
- (instancetype)initRandomWithGeneSequenceLength:(NSUInteger)length domain:(NSString *)domain;

- (instancetype)mateWithOrganism:(Organism *)mate crossoverMethod:(enum CrossoverMethod)crossoverMethod mutationRate:(CGFloat)mutationRate;

@end
