//
//  PopulationTests.m
//  Evolve
//
//  Created by Mike on 4/20/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Random.h"
#import "Population.h"

static NSInteger const kPopulationTestIterations = 10000;

@interface PopulationTests : XCTestCase

@end

@implementation PopulationTests

- (void)testInitWithOrganisms {
    for (NSInteger i = 0; i < kPopulationTestIterations; i++) {
        NSInteger numberOfOrganisms = [Random randomIntegerFromMin:2 toMax:20];
        NSMutableArray *organisms = [NSMutableArray arrayWithCapacity:numberOfOrganisms];

        for (NSInteger i = 0; i < numberOfOrganisms; i++) {
            [organisms addObject:[[Organism alloc] initRandomWithGeneSequenceLength:1 domain:@"abcd"]];
        }

        Population *population = [[Population alloc] initWithOrganisms:organisms];

        XCTAssertNotNil(population);
        XCTAssertNotNil(population.organisms);
        XCTAssertEqualObjects(population.organisms, organisms);
        XCTAssertEqual(population.organisms.count, numberOfOrganisms);
    }
}

- (void)testInitRandom {
    for (NSInteger i = 0; i < kPopulationTestIterations; i++) {
        NSInteger randomSize = [Random randomIntegerFromMin:2 toMax:20];
        NSInteger randomGeneSequenceLength = [Random randomIntegerFromMin:2 toMax:30];
        NSString *domain = @"abcdefg1234567";

        Population *population = [[Population alloc] initRandomPopulationWithSize:randomSize geneSequenceLength:randomGeneSequenceLength genomeDomain:domain];

        XCTAssertNotNil(population);
        XCTAssertNotNil(population.organisms);
        XCTAssertEqual(population.organisms.count, randomSize);

        for (Organism *organism in population.organisms) {
            XCTAssertNotNil(organism.genome);
            XCTAssertNotNil(organism.genome.sequence);
            XCTAssertEqual(organism.genome.sequence.length, randomGeneSequenceLength);
            XCTAssertNotNil(organism.genome.domain);
            XCTAssert([organism.genome.domain isEqualToString:domain]);
        }
    }
}

- (void)testInitWithInvalidOrganisms {
    void (^expressionBlock)() = ^{
        __unused Population *population = [[Population alloc] initWithOrganisms:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitWithInsufficientOrganisms {
    void (^expressionBlock)() = ^{
        Organism *theOnlyOne = [[Organism alloc] initRandomWithGeneSequenceLength:3 domain:@"abcd"];
        __unused Population *population = [[Population alloc] initWithOrganisms:@[theOnlyOne]];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithInsufficientCount {
    void (^expressionBlock)() = ^{
        __unused Population *population = [[Population alloc] initRandomPopulationWithSize:1 geneSequenceLength:4 genomeDomain:@"abcd"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithInvalidLength {
    void (^expressionBlock)() = ^{
        __unused Population *population = [[Population alloc] initRandomPopulationWithSize:10 geneSequenceLength:0 genomeDomain:@"abcd"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithNilDomain {
    void (^expressionBlock)() = ^{
        __unused Population *population = [[Population alloc] initRandomPopulationWithSize:10 geneSequenceLength:5 genomeDomain:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithInvalidDomain {
    void (^expressionBlock)() = ^{
        __unused Population *population = [[Population alloc] initRandomPopulationWithSize:10 geneSequenceLength:5 genomeDomain:@""];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

@end
