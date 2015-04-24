//
//  EvolutionManager.m
//  Evolve
//
//  Created by Mike on 4/20/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "EvolutionManager.h"

static CGFloat const kDefaultMutationRate = 0.05;
static CGFloat const kDefaultElitismPercentage = 0.10;
static NSInteger const kDefaultTournamentSize = 2;

@implementation EvolutionManager


#pragma mark - Initialization

- (instancetype)initWithPopulation:(Population *)population {
    self = [super init];

    if (!self) {
        return nil;
    }

    NSParameterAssert(population);

    // Assign our passed-in population.
    self.population = population;

    // Set our defaults.
    self.mutationRate = kDefaultMutationRate;
    self.elitismPercentage = kDefaultElitismPercentage;
    self.tournamentSize = self.population.organisms.count > 3 ? kDefaultTournamentSize : 1;

    return self;
}


#pragma mark - Selection

- (void)proceedWithSelectionAndBreeding {
    NSParameterAssert(self.delegate);

    // Get the starting organisms for this generation, and also get a copy of these organisms
    // sorted.
    NSArray *startingOrganisms = self.population.organisms;
    NSArray *sortedOrganisms = [self sortOrganismsByFitness:startingOrganisms];

    // Calculate the number of elite organisms that will live on to the next generation,
    // and get that number from the sorted list of organisms.
    NSInteger numberOfElites = [self calculateNumberOfElites];
    NSArray *elites = [sortedOrganisms subarrayWithRange:NSMakeRange(0, numberOfElites)];

    // Calculate the number of children we need to generate for the next generation, and pass
    // the unsorted list of all organisms to the method that will generate them.
    NSInteger numberOfChildren = [self calculateNumberOfOffspringFromEliteCount:numberOfElites];
    NSArray *offspring = [self generateOffspringFromOrganisms:startingOrganisms count:numberOfChildren];

    // Build our complete next generation of organisms, including the elite organisms that will live on to the next
    // generation, as well as the children - then shuffle the list to avoid any ordering bias.
    NSArray *nextGeneration = [self shuffleOrganisms:[elites arrayByAddingObjectsFromArray:offspring]];

    // Pass the information back to our delegate now that the population has completed a generation.
    if ([self.delegate respondsToSelector:@selector(evolutionManager:didCompetedGeneration:fittestOrganism:offspring:nextGeneration:)]) {
        [self.delegate evolutionManager:self didCompetedGeneration:self.currentGeneration fittestOrganism:[self fittestOrganismForCurrentGeneration] offspring:offspring nextGeneration:nextGeneration];
    }

    // Create a new population from the next generation.
    self.population = [[Population alloc] initWithOrganisms:nextGeneration];

    // Increment the current generation count.
    self.currentGeneration++;
}


#pragma mark - Organism Fitness

- (NSArray *)sortOrganismsByFitness:(NSArray *)organisms {
    return [organisms sortedArrayUsingComparator:^NSComparisonResult(Organism *orgA, Organism *orgB) {
        if (orgA.fitness < orgA.fitness) {
            return NSOrderedAscending;
        }

        else if (orgB.fitness > orgA.fitness) {
            return NSOrderedDescending;
        }

        else {
            return NSOrderedSame;
        }
    }];
}

- (Organism *)fittestOrganismForCurrentGeneration {
    Organism *fittestOrganism = [self.population.organisms firstObject];
    NSInteger highestFitness = fittestOrganism.fitness;

    for (Organism *organism in self.population.organisms) {
        if (organism.fitness > highestFitness) {
            highestFitness = organism.fitness;
            fittestOrganism = organism;
        }
    }

    return fittestOrganism;
}


#pragma mark - Selection

- (NSArray *)generateOffspringFromOrganisms:(NSArray *)parents count:(NSUInteger)offspringCount {
    NSParameterAssert(parents.count > 1);

    // Create our initially-empty offspring array.
    NSMutableArray *offspring = [NSMutableArray arrayWithCapacity:offspringCount];

    // We want to continue adding children until our predetermined count is met.
    while (offspring.count < offspringCount) {
        NSUInteger randomIndex1 = [Random randomIntegerFromMin:0 toMax:parents.count - self.tournamentSize - 1];
        NSUInteger randomIndex2 = [Random randomIntegerFromMin:0 toMax:parents.count - self.tournamentSize - 1];
        NSArray *tournament1Candidates = [parents subarrayWithRange:NSMakeRange(randomIndex1, self.tournamentSize)];
        NSArray *tournament2Candidates = [parents subarrayWithRange:NSMakeRange(randomIndex2, self.tournamentSize)];

        Organism *parent1 = [self winnerOfTournamentSelectionWithCandidates:tournament1Candidates];
        Organism *parent2 = [self winnerOfTournamentSelectionWithCandidates:tournament2Candidates];

        if (parent1 == parent2) {
            continue;
        }

        Organism *child = [Organism offspringFromParent1:parent1 parent2:parent2 mutationRate:self.mutationRate];

        // Add this child to our array of offspring.
        [offspring addObject:child];
    }

    return offspring;
}

- (Organism *)winnerOfTournamentSelectionWithCandidates:(NSArray *)candidates {
    NSParameterAssert(candidates.count > 0);

    Organism *fittestCandidate = [candidates firstObject];;

    for (NSInteger i = 1; i < candidates.count; i++) {
        Organism *candidate = candidates[i];
        if (candidate.fitness > fittestCandidate.fitness) {
            fittestCandidate = candidate;
        }
    }

    return fittestCandidate;
}

- (NSArray *)survivorsToNextGenerationWithCandidates:(NSArray *)candidates count:(NSUInteger)count {
    // Randomly choose the defined count of parents to return.
    NSMutableArray *potentialSurvivors = [NSMutableArray arrayWithArray:candidates];
    NSMutableArray *survivors = [NSMutableArray arrayWithCapacity:count];

    for (NSInteger i = 0; i < count; i++) {
        NSInteger randomIndex = [Random randomIntegerFromMin:0 toMax:potentialSurvivors.count - 1];
        Organism *survivor = potentialSurvivors[randomIndex];

        [survivors addObject:survivor];
        [potentialSurvivors removeObjectAtIndex:randomIndex];
    }

    return survivors;
}


#pragma mark - Calculations

- (NSInteger)calculateNumberOfElites {
    return (NSInteger)round(self.population.organisms.count * self.elitismPercentage);
}

- (NSInteger)calculateNumberOfOffspringFromEliteCount:(NSInteger)eliteCount {
    NSParameterAssert(eliteCount < self.population.organisms.count);

    return self.population.organisms.count - eliteCount;
}


#pragma mark - Setters for customizable / optional simulation params

- (void)setTournamentSize:(NSUInteger)tournamentSize {
    NSParameterAssert(tournamentSize > 0 && tournamentSize <= self.population.organisms.count / 2);

    _tournamentSize = tournamentSize;
}

- (void)setElitismPercentage:(CGFloat)percentageOfOrganismsThatSurvive {
    NSParameterAssert(percentageOfOrganismsThatSurvive >= 0.0 && percentageOfOrganismsThatSurvive < 1.0);

    _elitismPercentage = percentageOfOrganismsThatSurvive;
}

- (void)setMutationRate:(CGFloat)mutationRate {
    NSParameterAssert(mutationRate > 0.0 && mutationRate < 1.0);

    _mutationRate = mutationRate;
}



#pragma mark - Utils

- (NSArray *)shuffleOrganisms:(NSArray *)organisms {
    NSMutableArray *sourceOrganisms = [NSMutableArray arrayWithArray:organisms];
    NSMutableArray *shuffledOrganisms = [NSMutableArray arrayWithCapacity:organisms.count];

    NSUInteger count = organisms.count;
    for (NSUInteger i = 0; i < count; i++) {
        NSInteger randomIndex = [Random randomIntegerFromMin:0 toMax:sourceOrganisms.count - 1];

        Organism *randomOrganism = sourceOrganisms[randomIndex];

        [shuffledOrganisms addObject:randomOrganism];
        [sourceOrganisms removeObjectAtIndex:randomIndex];
    }
    
    return shuffledOrganisms;
}

@end
