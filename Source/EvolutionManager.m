//
//  EvolutionManager.m
//  Evolve
//
//  Created by Mike on 4/20/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "EvolutionManager.h"

static CGFloat const kDefaultReproductionPercentage = 0.33;
static CGFloat const kDefaultMutationRate = 0.05;
static CGFloat const kDefaultElitismPercentage = 0.10;

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
    self.reproductionPercentage = kDefaultReproductionPercentage;
    self.elitismPercentage = kDefaultElitismPercentage;

    return self;
}


#pragma mark - Generation cycle

- (void)proceedWithSelection {
    NSParameterAssert(self.delegate);

    // By now our delegate should have evaluated the fitness for our population, so let's sort
    // it by fitness - the fittest first.
    NSArray *sortedOrganisms = [self sortOrganismsByFitness:self.population.organisms];

    // The number of mates is the percentage of our total organisms that will get a chance to reproduce.
    NSInteger numberOfMates = [self calculateNumberOfMates];

    // TODO: The organisms selected to breed and survive to the next population should be randomly selected from
    // the entire population, with a stong bias towards fitness. Currently only the fittest x% are selected for breeding
    // and survival, which is a more optimal but less realistic approach. Sometimes very fit organisms are just unlucky,
    // and sometimes the nerd gets the girl...

    // Get the most fit organisms from our population that we just sorted.
    NSArray *fittestOrganisms = [sortedOrganisms subarrayWithRange:NSMakeRange(0, numberOfMates)];

    // Some of these organisms will get a chance to live on to the next generation and have another chance
    // at reproducing.
    NSInteger numberOfSurvivors = [self calculateNumberOfOrganismsSurviving];

    // The number of children that are created is the difference between our population count and the
    // previously calculated number of organisms that will survive until the next generation.
    NSInteger numberOfChildren = [self calculateNumberOfOffspringFromSurvivors:numberOfSurvivors];

    // Pass these organisms to our function that generates a given number of children randomly from these parents.
    NSArray *offspring = [self generateOffspringFromOrganisms:fittestOrganisms count:numberOfChildren];

    // From the pool of the fittest parents, get the lucky ones that will live on to the next generation.
    NSArray *survivors = [self survivorsToNextGenerationWithCandidates:fittestOrganisms count:numberOfSurvivors];

    // Build our complete next generation of organisms, including the parents that will live on to the next
    // generation, as well as their children - then shuffle the list to avoid any ordering bias.
    NSArray *nextGeneration = [self shuffleOrganisms:[survivors arrayByAddingObjectsFromArray:offspring]];

    // Pass the information back to our delegate now that the population has completed a generation.
    if ([self.delegate respondsToSelector:@selector(evolutionManager:didCompetedGeneration:selectedOrganisms:offspring:nextGeneration:)]) {
        [self.delegate evolutionManager:self didCompetedGeneration:self.currentGeneration selectedOrganisms:fittestOrganisms offspring:offspring nextGeneration:nextGeneration];
    }

    // Create a new population from the next generation.
    self.population = [[Population alloc] initWithOrganisms:nextGeneration];

    // Increment the current generation count.
    self.currentGeneration++;
}

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

- (NSInteger)calculateNumberOfMates {
    return (NSInteger)round(self.population.organisms.count * self.reproductionPercentage);
}

- (NSInteger)calculateNumberOfOrganismsSurviving {
    return (NSInteger)round(self.population.organisms.count * self.elitismPercentage);
}

- (NSInteger)calculateNumberOfOffspringFromSurvivors:(NSInteger)survivorCount {
    NSParameterAssert(survivorCount < self.population.organisms.count);

    return self.population.organisms.count - survivorCount;
}

- (NSArray *)generateOffspringFromOrganisms:(NSArray *)parents count:(NSInteger)offspringCount {
    NSParameterAssert(parents.count > 1);

    // Create our initially-empty offspring array.
    NSMutableArray *offspring = [NSMutableArray arrayWithCapacity:offspringCount];

    // We want to continue adding children until our predetermined count is met.
    while (offspring.count < offspringCount) {

        // Choose two random organisms to be the parents, ensuring we don't choose the same
        // organism twice as this simulates sexual reproduction, rather than asexual reproduction.
        NSInteger randomOrganismIndexA = [Random randomIntegerFromMin:0 toMax:parents.count - 1];
        NSInteger randomOrganismIndexB = [Random randomIntegerFromMin:0 toMax:parents.count - 1];

        // If the two random indexes are the same, skip this iteration.
        if (randomOrganismIndexA == randomOrganismIndexB) {
            continue;
        }

        // Take these two parents and... well son... you see... When a mommy and
        // a daddy love eachother very much...
        Organism *parent1 = parents[randomOrganismIndexA];
        Organism *parent2 = parents[randomOrganismIndexB];
        Organism *child = [Organism offspringFromParent1:parent1 parent2:parent2 mutationRate:self.mutationRate];

        // Add this child to our array of offspring.
        [offspring addObject:child];
    }

    return offspring;
}

- (NSArray *)survivorsToNextGenerationWithCandidates:(NSArray *)candidates count:(NSInteger)count {
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


#pragma mark - Setters for customizable / optional simulation params

- (void)setReproductionPercentage:(CGFloat)percentageOfOrganismsThatReproduce {
    NSParameterAssert(percentageOfOrganismsThatReproduce >= 0.0 && percentageOfOrganismsThatReproduce <= 1.0);

    _reproductionPercentage = percentageOfOrganismsThatReproduce;
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
