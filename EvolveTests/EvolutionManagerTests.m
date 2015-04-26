//
//  EvolutionManagerTests.m
//  Evolve
//
//  Created by Mike on 4/21/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "EvolutionManager.h"

static NSInteger const kEvolutionManagerTestIterations = 250;


@interface EvolutionManager (Testing)

- (NSArray *)sortOrganismsByFitness:(NSArray *)organisms;
- (Organism *)fittestOrganismForCurrentGeneration;
- (NSArray *)generateOffspringFromOrganisms:(NSArray *)parents count:(NSInteger)offspringCount;
- (Organism *)winnerOfTournamentSelectionWithCandidates:(NSArray *)candidates;
- (NSArray *)survivorsToNextGenerationWithCandidates:(NSArray *)candidates count:(NSInteger)count;
- (NSArray *)filterDead:(NSArray *)allOrganisms;

- (NSInteger)calculateNumberOfElitesForOrganismCount:(NSUInteger)count;
- (NSInteger)calculateNumberOfOffspringFromEliteCount:(NSInteger)eliteCount;

@end


@interface EvolutionManagerTests : XCTestCase <EvolutionDelegate> {
    EvolutionManager *_testManager;
}

@end

@implementation EvolutionManagerTests

- (void)setUp {
    [super setUp];

    NSInteger randomNumberOfOrganisms = [Random randomIntegerFromMin:100 toMax:500];
    NSMutableArray *organisms = [NSMutableArray arrayWithCapacity:randomNumberOfOrganisms];

    for (NSInteger i = 0; i < randomNumberOfOrganisms; i++) {
        Genome *genome = [[Genome alloc] initRandomGenomeWithLength:5 domain:@"abcd"];
        [organisms addObject:[[Organism alloc] initWithGenome:genome]];
    }

    Population *testPopulation = [[Population alloc] initWithOrganisms:organisms];

    _testManager = [[EvolutionManager alloc] initWithPopulation:testPopulation];
    _testManager.delegate = self;
}

- (void)tearDown {
    _testManager = nil;

    [super tearDown];
}


#pragma mark - Initialization

- (void)testInitWithPopulation {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomSize = [Random randomIntegerFromMin:2 toMax:100];
        NSInteger randomLength = [Random randomIntegerFromMin:4 toMax:10];
        NSString *domain = @"abcd";
        Population *population = [[Population alloc] initRandomPopulationWithSize:randomSize geneSequenceLength:randomLength genomeDomain:domain];
        EvolutionManager *manager = [[EvolutionManager alloc] initWithPopulation:population];

        XCTAssertNotNil(manager);
        XCTAssertEqualObjects(manager.population, population);
    }
}

- (void)testInitWithInvalidPopulation {
    void (^expressionBlock)() = ^{
        __unused EvolutionManager *manager = [[EvolutionManager alloc] initWithPopulation:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}


#pragma mark - Sorting / filtering

- (void)testSortOrganismsByFitness {
    NSInteger minFitness = 0;
    NSInteger maxFitness = 100;
    for (Organism *organism in _testManager.population.organisms) {
        organism.fitness = [Random randomIntegerFromMin:minFitness toMax:maxFitness];
    }

    NSArray *sortedOrganisms = [_testManager sortOrganismsByFitness:_testManager.population.organisms];

    NSInteger previousFitness = maxFitness + 1;
    for (Organism *organism in sortedOrganisms) {
        XCTAssert(organism.fitness <= maxFitness);
        XCTAssert(organism.fitness <= previousFitness);
        XCTAssert(organism.fitness >= minFitness);

        previousFitness = organism.fitness;
    }
}

- (void)testSortOrganismsByFitnessWithEmptyArray {
    NSArray *sortedOrganisms = [_testManager sortOrganismsByFitness:@[]];
    XCTAssertNotNil(sortedOrganisms);
}

- (void)testSortOrganismsByFitnessWithNilArray {
    NSArray *sortedOrganisms = [_testManager sortOrganismsByFitness:nil];
    XCTAssertNil(sortedOrganisms);
}

- (void)testFilteringTheDead {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomNumberOfOrganisms = [Random randomIntegerFromMin:50 toMax:100];
        NSMutableArray *organisms = [NSMutableArray arrayWithCapacity:randomNumberOfOrganisms];

        for (NSInteger j = 0; j < randomNumberOfOrganisms; j++) {
            Organism *organism = [[Organism alloc] initRandomWithGeneSequenceLength:5 domain:@"ABCD"];
            [organisms addObject:organism];
        }

        NSInteger numberOfCasualties = 0;
        for (Organism *organism in organisms) {
            if ([Random randomIntegerFromMin:0 toMax:1]) {
                [organism kill];

                numberOfCasualties++;
            }
        }

        NSArray *filteredOrganisms = [_testManager filterDead:organisms];

        XCTAssertEqual(filteredOrganisms.count, organisms.count - numberOfCasualties);
    }
}


#pragma mark - Getting fittest organism

- (void)testGetFittestOrganism {
    Organism *weakerA = [[Organism alloc] initWithGenome:[Genome new]];
    weakerA.fitness = [Random randomIntegerFromMin:1 toMax:100];

    Organism *weakerB = [[Organism alloc] initWithGenome:[Genome new]];
    weakerB.fitness = weakerA.fitness + 1;

    Organism *weakerC = [[Organism alloc] initWithGenome:[Genome new]];
    weakerC.fitness = weakerA.fitness;

    Organism *fittest = [[Organism alloc] initWithGenome:[Genome new]];
    fittest.fitness = weakerB.fitness + 1;

    Population *population = [[Population alloc] initWithOrganisms:@[weakerA, weakerB, fittest, weakerC]];
    _testManager.population = population;

    Organism *generatedFittest = [_testManager fittestOrganismForCurrentGeneration];

    XCTAssertNotNil(fittest);
    XCTAssertEqualObjects(generatedFittest, fittest);
}

- (void)testGetFittestOrganismFromEmptySet {
    _testManager.population.organisms = @[];

    Organism *generatedFittest = [_testManager fittestOrganismForCurrentGeneration];

    XCTAssertNil(generatedFittest);
}

- (void)testGetFittestOrganismFromNilSet {
    _testManager.population.organisms = nil;

    Organism *generatedFittest = [_testManager fittestOrganismForCurrentGeneration];

    XCTAssertNil(generatedFittest);
}


#pragma mark - Calculations

- (void)testCalcuateNumberOfElites {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        CGFloat survivalRate = [Random randomIntegerFromMin:1 toMax:99] / 100.0;
        _testManager.elitismPercentage = survivalRate;

        NSInteger numberOfSurvivors = [_testManager calculateNumberOfElitesForOrganismCount:_testManager.population.organisms.count];

        XCTAssertEqual(numberOfSurvivors, round(_testManager.population.organisms.count * survivalRate));
    }
}

- (void)testCalculateNumberOfOffspring {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomSurvivorCount = [Random randomIntegerFromMin:0 toMax:_testManager.population.organisms.count - 1];
        NSInteger numberOfOffspring = [_testManager calculateNumberOfOffspringFromEliteCount:randomSurvivorCount];

        XCTAssertEqual(numberOfOffspring, _testManager.population.organisms.count - randomSurvivorCount);
    }
}


#pragma mark - Selection

- (void)testProceedWithSelection {
    for (NSInteger i = 1; i < kEvolutionManagerTestIterations; i++) {
        NSInteger beforeOrganismCount = _testManager.population.organisms.count;

        [_testManager proceedWithSelectionAndBreeding];

        NSInteger afterOrganismCount = _testManager.population.organisms.count;

        XCTAssertEqual(beforeOrganismCount, afterOrganismCount);
        XCTAssertEqual(_testManager.currentGeneration, i);
    }
}

- (void)testProceedWithSelectionWithoutDelegate {
    void (^expressionBlock)() = ^{
        _testManager.delegate = nil;
        [_testManager proceedWithSelectionAndBreeding];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}


#pragma mark - Setters

- (void)testSetters {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSUInteger randomTournamentSize = [Random randomIntegerFromMin:2 toMax:10];
        CGFloat randomSurvivalRate = [Random randomIntegerFromMin:1 toMax:99] / 100.0;
        CGFloat randomMutationRate = [Random randomIntegerFromMin:1 toMax:99] / 100.0;

        _testManager.tournamentSize = randomTournamentSize;
        _testManager.elitismPercentage = randomSurvivalRate;
        _testManager.mutationRate = randomMutationRate;

        XCTAssertEqual(_testManager.tournamentSize, randomTournamentSize);
        XCTAssertEqual(_testManager.elitismPercentage, randomSurvivalRate);
        XCTAssertEqual(_testManager.mutationRate, randomMutationRate);
    }
}

- (void)testInvalidTournamentSize {
    void (^expressionBlock)() = ^{
        _testManager.tournamentSize = 0;
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInvalidElitismRate {
    void (^expressionBlock)() = ^{
        _testManager.elitismPercentage = 1.0;
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInvalidMutationRate {
    void (^expressionBlock)() = ^{
        _testManager.mutationRate = 1.1;
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}


#pragma mark - Generating offspring

- (void)testGenerateOffspring {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomCount = [Random randomIntegerFromMin:2 toMax:100];
        NSArray *offspring = [_testManager generateOffspringFromOrganisms:_testManager.population.organisms count:randomCount];

        XCTAssertNotNil(offspring);
        XCTAssertEqual(offspring.count, randomCount);
    }
}


#pragma mark - Survivor 

- (void)testSurvivorsToNextGeneration {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomCount = [Random randomIntegerFromMin:2 toMax:100];
        NSArray *survivors = [_testManager survivorsToNextGenerationWithCandidates:_testManager.population.organisms count:randomCount];

        XCTAssertNotNil(survivors);
        XCTAssertEqual(survivors.count, randomCount);
    }
}


#pragma mark - Tournament selection

- (void)testTournamentSelection {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomIndexA = [Random randomIntegerFromMin:0 toMax:_testManager.population.organisms.count - 1];
        Organism *organismA = _testManager.population.organisms[randomIndexA];
        organismA.fitness = [Random randomIntegerFromMin:1 toMax:100];

        NSInteger randomIndexB = [Random randomIntegerFromMin:0 toMax:_testManager.population.organisms.count - 1];
        Organism *organismB = _testManager.population.organisms[randomIndexB];
        organismB.fitness = [Random randomIntegerFromMin:1 toMax:100];

        Organism *winner = [_testManager winnerOfTournamentSelectionWithCandidates:@[organismA, organismB]];

        XCTAssertNotNil(winner);

        if (organismA.fitness > organismB.fitness || organismA.fitness == organismB.fitness) {
            XCTAssertEqualObjects(winner, organismA);
        }

        else {
            XCTAssertEqualObjects(winner, organismB);
        }
    }
}

- (void)testTournamentSelectionWithoutMinimumCount {
    void (^expressionBlock)() = ^{
        __unused Organism *winner = [_testManager winnerOfTournamentSelectionWithCandidates:@[]];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testTournamentSelectionWithNilSet {
    void (^expressionBlock)() = ^{
        __unused Organism *winner = [_testManager winnerOfTournamentSelectionWithCandidates:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)evolutionManager:(EvolutionManager *)evolutionManager didCompetedGeneration:(NSUInteger)generation fittestOrganism:(Organism *)fittestOrganism offspring:(NSArray *)offspring nextGeneration:(NSArray *)nextGeneration {};

@end
