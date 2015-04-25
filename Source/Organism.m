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

- (instancetype)mateWithOrganism:(Organism *)mate crossoverMethod:(enum CrossoverMethod)crossoverMethod mutationRate:(CGFloat)mutationRate {
    NSParameterAssert(mate);
    NSParameterAssert([self.genome.domain isEqualToString:mate.genome.domain]);
    NSParameterAssert(self.genome.sequence.length == mate.genome.sequence.length);
    NSParameterAssert(mutationRate >= 0 && mutationRate <= 1);

    // Generate the offspring's gene sequence from ours and our mate's, using the defined crossover method.
    NSString *offspringGeneSequence = [self generateChildGeneSequenceFromMate:mate crossoverMethod:crossoverMethod];

    // Create the child's genome with the parent's same configuration and the crossed over genetic pattern.
    Genome *childsGenome = [[Genome alloc] initWithGeneSequence:offspringGeneSequence domain:self.genome.domain];

    // Tell the genome to handle mutation given the provided mutation rate.
    [childsGenome handleMutationWithRate:mutationRate];

    // Create the child with this genome.
    Organism *child = [[Organism alloc] initWithGenome:childsGenome];
    
    return child;
}

- (NSString *)generateChildGeneSequenceFromMate:(Organism *)mate crossoverMethod:(CrossoverMethod)crossoverMethod {
    NSString *ourGeneSequence = self.genome.sequence;
    NSString *mateGeneSequence = mate.genome.sequence;

    switch (crossoverMethod) {

        // Randomly generate a crossover point and combine the parent's genomes there - which will
        // be the child's starting gene sequence.
        case CrossoverMethodOnePoint: {
            NSInteger crossoverPoint = [Random randomIntegerFromMin:1 toMax:ourGeneSequence.length - 2];
            NSString *ourContribution = [ourGeneSequence substringToIndex:crossoverPoint];
            NSString *mateContribution = [mateGeneSequence substringFromIndex:crossoverPoint];

            return [ourContribution stringByAppendingString:mateContribution];
        }

        // The same as one-point, although two points (one range) are chosen and the genome is split on those,
        // with the our genome contributing to the first and last 1/3 of the genes and the mate
        // contributing to the middle 1/3.
        case CrossoverMethodTwoPoint: {
            NSRange rangeForCrossover = [[self class] generateRangeForTwoPointCrossoverFromLength:self.genome.sequence.length];

            NSString *ourFirstContribution = [ourGeneSequence substringToIndex:rangeForCrossover.location];
            NSString *mateContribution = [mateGeneSequence substringWithRange:rangeForCrossover];
            NSString *ourSecondContribution = [ourGeneSequence substringFromIndex:rangeForCrossover.location + rangeForCrossover.length];

            return [[ourFirstContribution stringByAppendingString:mateContribution] stringByAppendingString:ourSecondContribution];
        }
    }
}


#pragma mark - Crossover Utils

+ (NSRange)generateRangeForTwoPointCrossoverFromLength:(NSUInteger)geneSequenceLength {
    NSParameterAssert(geneSequenceLength >= kMinimumGeneSequenceLength);

    NSInteger beginningOfMateRange = [Random randomIntegerFromMin:1 toMax:floor((geneSequenceLength / 2.0)) - 1];
    NSInteger lengthOfMateRange = [Random randomIntegerFromMin:1 toMax:geneSequenceLength - beginningOfMateRange - 2];
    return NSMakeRange(beginningOfMateRange, lengthOfMateRange);
}


#pragma mark - Debugging

- (NSString *)debugDescription {
    return @{
             @"geneSequence": self.genome.sequence,
             @"fitness": @(self.fitness)
             }.description;
}

@end
