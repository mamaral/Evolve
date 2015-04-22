//
//  Population.m
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "Population.h"
#import "Random.h"

@implementation Population


#pragma mark - Initialization

- (instancetype)initRandomPopulationWithSize:(NSUInteger)size geneSequenceLength:(NSUInteger)geneSequenceLength genomeDomain:(NSString *)domain {
    return [self initWithOrganisms:[self generateRandomPopulationWithSize:size geneSequenceLength:geneSequenceLength genomeDomain:domain]];
}

- (instancetype)initWithOrganisms:(NSArray *)organisms {
    self = [super init];

    if (!self) {
        return nil;
    }

    NSParameterAssert(organisms);
    NSParameterAssert(organisms.count >= 2);

    self.organisms = organisms;

    return self;
}


#pragma mark - Randomization

- (NSArray *)generateRandomPopulationWithSize:(NSUInteger)size geneSequenceLength:(NSUInteger)geneSequenceLength genomeDomain:(NSString *)domain {
    NSMutableArray *startingOrganisms = [NSMutableArray arrayWithCapacity:size];

    for (NSInteger i = 0; i < size; i++) {
        [startingOrganisms addObject:[[Organism alloc] initRandomWithGeneSequenceLength:geneSequenceLength domain:domain]];
    }

    return startingOrganisms;
}


@end
