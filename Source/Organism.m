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
    return [self initWithChomosome:[[Chromosome alloc] initRandomChromosomeWithLength:length domain:domain]];
}


- (instancetype)initWithChomosome:(Chromosome *)chromosome {
    self = [super init];

    if (!self) {
        return nil;
    }

    NSParameterAssert(chromosome);

    self.chromosome = chromosome;

    return self;
}


#pragma mark - Reproduction

+ (instancetype)offspringFromParent1:(Organism *)parent1 parent2:(Organism *)parent2 mutationRate:(CGFloat)mutationRate {
    NSParameterAssert(parent1);
    NSParameterAssert(parent2);
    NSParameterAssert([parent1.chromosome.domain isEqualToString:parent2.chromosome.domain]);
    NSParameterAssert(parent1.chromosome.geneSequence.length == parent2.chromosome.geneSequence.length);
    NSParameterAssert(mutationRate >= 0 && mutationRate <= 1);
    
    // Randomly generate a crossover point and combine the parent's chromosomes there - which will
    // be the child's starting gene sequence.
    NSInteger crossoverPoint = [Random randomIntegerFromMin:0 toMax:parent1.chromosome.geneSequence.length - 1];
    NSString *parent1Contribution = [parent1.chromosome.geneSequence substringToIndex:crossoverPoint];
    NSString *parent2Contribution = [parent2.chromosome.geneSequence substringFromIndex:crossoverPoint];
    NSString *offspringGeneSequence = [parent1Contribution stringByAppendingString:parent2Contribution];

    // Create the child's chromosome with the parent's same configuration and the crossed over genetic pattern.
    Chromosome *childsChromosome = [[Chromosome alloc] initWithGeneSequence:offspringGeneSequence domain:parent1.chromosome.domain];

    // Tell the chromosome to handle mutation given the provided mutation rate.
    [childsChromosome handleMutationWithRate:mutationRate];

    // Create the child with this chromosome.
    Organism *child = [[Organism alloc] initWithChomosome:childsChromosome];
    
    return child;
}


#pragma mark - Debugging

- (NSString *)debugDescription {
    return @{
             @"geneSequence": self.chromosome.geneSequence,
             @"fitness": @(self.fitness)
             }.description;
}

@end
