//
//  Organism.m
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "Organism.h"
#import "Random.h"

@implementation Organism


#pragma mark - Initializers

- (instancetype)initRandomWithGeneSequenceLength:(NSUInteger)length domain:(NSString *)domain {
    return [self initWithGenome:[[Genome alloc] initRandomGenomeWithLength:length domain:domain]];
}


- (instancetype)initWithGenome:(Genome *)genome {
    self = [super init];

    if (!self) {
        return nil;
    }

    NSParameterAssert(genome);

    self.genome = genome;

    return self;
}


#pragma mark - Reproduction

+ (instancetype)offspringFromParent1:(Organism *)parent1 parent2:(Organism *)parent2 mutationRate:(CGFloat)mutationRate {
    NSParameterAssert(parent1);
    NSParameterAssert(parent2);
    NSParameterAssert([parent1.genome.domain isEqualToString:parent2.genome.domain]);
    NSParameterAssert(parent1.genome.sequence.length == parent2.genome.sequence.length);
    NSParameterAssert(mutationRate >= 0 && mutationRate <= 1);
    
    // Randomly generate a crossover point and combine the parent's genomes there - which will
    // be the child's starting gene sequence.
    NSInteger crossoverPoint = [Random randomIntegerFromMin:0 toMax:parent1.genome.sequence.length - 1];
    NSString *parent1Contribution = [parent1.genome.sequence substringToIndex:crossoverPoint];
    NSString *parent2Contribution = [parent2.genome.sequence substringFromIndex:crossoverPoint];
    NSString *offspringGeneSequence = [parent1Contribution stringByAppendingString:parent2Contribution];

    // Create the child's genome with the parent's same configuration and the crossed over genetic pattern.
    Genome *childsGenome = [[Genome alloc] initWithGeneSequence:offspringGeneSequence domain:parent1.genome.domain];

    // Tell the genome to handle mutation given the provided mutation rate.
    [childsGenome handleMutationWithRate:mutationRate];

    // Create the child with this genome.
    Organism *child = [[Organism alloc] initWithGenome:childsGenome];
    
    return child;
}


#pragma mark - Debugging

- (NSString *)debugDescription {
    return @{
             @"geneSequence": self.genome.sequence,
             @"fitness": @(self.fitness)
             }.description;
}

@end
