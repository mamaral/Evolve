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
- (NSInteger)calculateNumberOfMates;
- (NSInteger)calculateNumberOfOrganismsSurviving;
- (NSInteger)calculateNumberOfOffspringFromSurvivors:(NSInteger)survivorCount;
- (NSArray *)generateOffspringFromOrganisms:(NSArray *)parents count:(NSInteger)offspringCount;
- (NSArray *)survivorsToNextGenerationWithCandidates:(NSArray *)candidates count:(NSInteger)count;

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

- (void)testInitWithPopulation {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomSize = [Random randomIntegerFromMin:2 toMax:100];
        NSInteger randomLength = [Random randomIntegerFromMin:1 toMax:10];
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

- (void)testCalcuateNumberOfMates {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        CGFloat reproductionRate = [Random randomIntegerFromMin:1 toMax:100] / 100.0;
        _testManager.percentageOfOrganismsThatReproduce = reproductionRate;

        NSInteger numberOfMates = [_testManager calculateNumberOfMates];

        XCTAssertEqual(numberOfMates, round(_testManager.population.organisms.count * reproductionRate));
    }
}

- (void)testCalcuateNumberOfSurvivors {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        CGFloat survivalRate = [Random randomIntegerFromMin:1 toMax:99] / 100.0;
        _testManager.percentageOfOrganismsThatSurvive = survivalRate;

        NSInteger numberOfSurvivors = [_testManager calculateNumberOfOrganismsSurviving];

        XCTAssertEqual(numberOfSurvivors, round(_testManager.population.organisms.count * survivalRate));
    }
}

- (void)testCalculateNumberOfOffspring {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomSurvivorCount = [Random randomIntegerFromMin:0 toMax:_testManager.population.organisms.count - 1];
        NSInteger numberOfOffspring = [_testManager calculateNumberOfOffspringFromSurvivors:randomSurvivorCount];

        XCTAssertEqual(numberOfOffspring, _testManager.population.organisms.count - randomSurvivorCount);
    }
}

- (void)testProcessNextGeneration {
    for (NSInteger i = 1; i < kEvolutionManagerTestIterations; i++) {
        NSInteger beforeOrganismCount = _testManager.population.organisms.count;

        [_testManager processNextGeneration];

        NSInteger afterOrganismCount = _testManager.population.organisms.count;

        XCTAssertEqual(beforeOrganismCount, afterOrganismCount);
        XCTAssertEqual(_testManager.currentGeneration, i);
    }
}

- (void)testProcessNextGenerationWithoutDelegate {
    void (^expressionBlock)() = ^{
        _testManager.delegate = nil;
        [_testManager processNextGeneration];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)population:(Population *)population didCompetedGeneration:(NSUInteger)generation fittestOrganisms:(NSArray *)fittestOrganisms offspring:(NSArray *)offspring completeNextGeneration:(NSArray *)nextGeneration {

}

- (void)testSetters {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        CGFloat randomReproductionRate = [Random randomIntegerFromMin:1 toMax:99] / 100.0;
        CGFloat randomSurvivalRate = [Random randomIntegerFromMin:1 toMax:99] / 100.0;
        CGFloat randomMutationRate = [Random randomIntegerFromMin:1 toMax:99] / 100.0;

        _testManager.percentageOfOrganismsThatReproduce = randomReproductionRate;
        _testManager.percentageOfOrganismsThatSurvive = randomSurvivalRate;
        _testManager.mutationRate = randomMutationRate;

        XCTAssertEqual(_testManager.percentageOfOrganismsThatReproduce, randomReproductionRate);
        XCTAssertEqual(_testManager.percentageOfOrganismsThatSurvive, randomSurvivalRate);
        XCTAssertEqual(_testManager.mutationRate, randomMutationRate);
    }
}

- (void)testInvalidReproductionRate {
    void (^expressionBlock)() = ^{
        _testManager.percentageOfOrganismsThatReproduce = 1.1;
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInvalidSurvivalRate {
    void (^expressionBlock)() = ^{
        _testManager.percentageOfOrganismsThatSurvive = 1.0;
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInvalidMutationRate {
    void (^expressionBlock)() = ^{
        _testManager.mutationRate = 1.1;
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testGenerateOffspring {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomCount = [Random randomIntegerFromMin:2 toMax:100];
        NSArray *offspring = [_testManager generateOffspringFromOrganisms:_testManager.population.organisms count:randomCount];

        XCTAssertNotNil(offspring);
        XCTAssertEqual(offspring.count, randomCount);
    }
}

- (void)testSurvivorsToNextGeneration {
    for (NSInteger i = 0; i < kEvolutionManagerTestIterations; i++) {
        NSInteger randomCount = [Random randomIntegerFromMin:2 toMax:100];
        NSArray *survivors = [_testManager survivorsToNextGenerationWithCandidates:_testManager.population.organisms count:randomCount];

        XCTAssertNotNil(survivors);
        XCTAssertEqual(survivors.count, randomCount);
    }
}

@end
