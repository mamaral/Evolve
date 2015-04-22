//
//  OrganismTests.m
//  Evolve
//
//  Created by Mike on 4/20/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Organism.h"
#import "Random.h"

static NSInteger const kOrganismTestIterations = 10000;

@interface OrganismTests : XCTestCase

@end

@implementation OrganismTests

- (void)testInitWithGenome {
    for (NSInteger i = 0; i < kOrganismTestIterations; i++) {
        Genome *genome = [[Genome alloc] initRandomGenomeWithLength:5 domain:@"abcd"];

        Organism *organism = [[Organism alloc] initWithGenome:genome];

        XCTAssertNotNil(organism);
        XCTAssertNotNil(organism.genome);
        XCTAssertEqualObjects(organism.genome, genome);
        XCTAssertEqual(organism.fitness, 0);
    }
}

- (void)testInitRandom {
    NSString *testDomain = @"abcdefg 123456";

    for (NSInteger i = 0; i < kOrganismTestIterations; i++) {
        NSInteger randomLength = [Random randomIntegerFromMin:1 toMax:25];
        Organism *organism = [[Organism alloc] initRandomWithGeneSequenceLength:randomLength domain:testDomain];

        XCTAssertNotNil(organism);
        XCTAssertNotNil(organism.genome);
        XCTAssertEqual(organism.genome.sequence.length, randomLength);
        XCTAssert([organism.genome.domain isEqualToString:testDomain]);
        XCTAssertEqual(organism.fitness, 0);
    }
}

- (void)testOrganismFitness {
    for (NSInteger i = 0; i < kOrganismTestIterations; i++) {
        Organism *organism = [[Organism alloc] initRandomWithGeneSequenceLength:4 domain:@"abcd"];

        NSInteger randomFitness = [Random randomIntegerFromMin:-10000 toMax:10000];
        organism.fitness = randomFitness;

        XCTAssertEqual(organism.fitness, randomFitness);
    }
}

- (void)testInitWithInvalidGenome {
    void (^expressionBlock)() = ^{
        __unused Organism *organism = [[Organism alloc] initWithGenome:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithInvalidLength {
    void (^expressionBlock)() = ^{
        __unused Organism *organism = [[Organism alloc] initRandomWithGeneSequenceLength:0 domain:@"abcd"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithNilDomain {
    void (^expressionBlock)() = ^{
        __unused Organism *organism = [[Organism alloc] initRandomWithGeneSequenceLength:5 domain:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithInvalidDomain {
    void (^expressionBlock)() = ^{
        __unused Organism *organism = [[Organism alloc] initRandomWithGeneSequenceLength:5 domain:@""];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testGenerateOffspring {
    NSInteger testGeneSequenceLength = 20;
    NSString *testDomain = @"abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";

    for (NSInteger i = 0; i < kOrganismTestIterations; i++) {
        Organism *parent1 = [[Organism alloc] initRandomWithGeneSequenceLength:testGeneSequenceLength domain:testDomain];
        Organism *parent2 = [[Organism alloc] initRandomWithGeneSequenceLength:testGeneSequenceLength domain:testDomain];
        Organism *offspring = [Organism offspringFromParent1:parent1 parent2:parent2 mutationRate:0.0];

        XCTAssertNotNil(offspring);
        XCTAssertNotNil(offspring.genome);
        XCTAssert([offspring.genome.domain isEqualToString:parent1.genome.domain]);
        XCTAssert([offspring.genome.domain isEqualToString:parent2.genome.domain]);
        XCTAssertEqual(offspring.genome.sequence.length, parent1.genome.sequence.length);
        XCTAssertEqual(offspring.genome.sequence.length, parent2.genome.sequence.length);

        NSInteger correctGenes = 0;

        NSString *parent1GeneSequence = parent1.genome.sequence;
        NSString *parent2GeneSequence = parent2.genome.sequence;
        NSString *offspringGeneSequence = offspring.genome.sequence;

        for (NSInteger geneIndex = 0; geneIndex < testGeneSequenceLength; geneIndex++) {
            if ([offspringGeneSequence characterAtIndex:geneIndex] == [parent1GeneSequence characterAtIndex:geneIndex] || [offspringGeneSequence characterAtIndex:geneIndex] == [parent2GeneSequence characterAtIndex:geneIndex]) {
                correctGenes++;
            }
        }

        XCTAssertEqual(correctGenes, testGeneSequenceLength);
    }
}

- (void)testGenerateOffspringWithInvalidParent1 {
    void (^expressionBlock)() = ^{
        __unused Organism *offspring = [Organism offspringFromParent1:nil parent2:[Organism new] mutationRate:0.0];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testGenerateOffspringWithInvalidParent2 {
    void (^expressionBlock)() = ^{
        __unused Organism *offspring = [Organism offspringFromParent1:[Organism new] parent2:nil mutationRate:0.0];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testGenerateOffspringWithInvalidMutationRate {
    void (^expressionBlock)() = ^{
        NSString *testDomain = @"abcd";
        NSInteger testLength = 4;
        Organism *parent1 = [[Organism alloc] initRandomWithGeneSequenceLength:testLength domain:testDomain];
        Organism *parent2 = [[Organism alloc] initRandomWithGeneSequenceLength:testLength domain:testDomain];
        __unused Organism *offspring = [Organism offspringFromParent1:parent1 parent2:parent2 mutationRate:1.5];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testGenerateOffspringWithMismatchingParentLength {
    void (^expressionBlock)() = ^{
        NSString *testDomain = @"abcd";
        Organism *parent1 = [[Organism alloc] initRandomWithGeneSequenceLength:3 domain:testDomain];
        Organism *parent2 = [[Organism alloc] initRandomWithGeneSequenceLength:4 domain:testDomain];
        __unused Organism *offspring = [Organism offspringFromParent1:parent1 parent2:parent2 mutationRate:0.0];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testGenerateOffspringWithMismatchingParentDomain {
    void (^expressionBlock)() = ^{
        NSInteger testLength = 4;
        Organism *parent1 = [[Organism alloc] initRandomWithGeneSequenceLength:testLength domain:@"abc"];
        Organism *parent2 = [[Organism alloc] initRandomWithGeneSequenceLength:testLength domain:@"123"];
        __unused Organism *offspring = [Organism offspringFromParent1:parent1 parent2:parent2 mutationRate:0.0];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

@end
