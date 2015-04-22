//
//  ChromosomeTests.m
//  Evolve
//
//  Created by Mike on 4/20/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Chromosome.h"
#import "Random.h"

static NSInteger const kChromosomeTestIterations = 10000;

@interface ChromosomeTests : XCTestCase

@end

@implementation ChromosomeTests

- (void)testInitWithGeneSequenceAndDomain {
    NSString *entireDomain = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";
    
    for (NSInteger i = 0; i < kChromosomeTestIterations; i++) {
        NSInteger randomSequenceLength = [Random randomIntegerFromMin:1 toMax:50];
        NSInteger randomDomainLength = [Random randomIntegerFromMin:1 toMax:25];
        NSString *randomDomain = [Random randomGeneSequenceWithLength:randomDomainLength domain:entireDomain];
        NSString *randomGeneSequence = [Random randomGeneSequenceWithLength:randomSequenceLength domain:randomDomain];

        Chromosome *chromosome = [[Chromosome alloc] initWithGeneSequence:randomGeneSequence domain:randomDomain];

        XCTAssertNotNil(chromosome);
        XCTAssert([chromosome.geneSequence isEqualToString:randomGeneSequence]);
        XCTAssert([chromosome.domain isEqualToString:randomDomain]);
    }
}

- (void)testInitRandomWithLengthAndDomain {
    NSString *entireDomain = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";

    for (NSInteger i = 0; i < kChromosomeTestIterations; i++) {
        NSInteger randomSequenceLength = [Random randomIntegerFromMin:1 toMax:50];
        NSInteger randomDomainLength = [Random randomIntegerFromMin:1 toMax:25];
        NSString *randomDomain = [Random randomGeneSequenceWithLength:randomDomainLength domain:entireDomain];

        Chromosome *chromosome = [[Chromosome alloc] initRandomChromosomeWithLength:randomSequenceLength domain:randomDomain];

        XCTAssertNotNil(chromosome);
        XCTAssertEqual(chromosome.geneSequence.length, randomSequenceLength);
        XCTAssert([chromosome.domain isEqualToString:randomDomain]);
    }
}

- (void)testInitWithNilGeneSequence {
    void (^expressionBlock)() = ^{
        __unused Chromosome *testChromosome = [[Chromosome alloc] initWithGeneSequence:nil domain:@"abcd"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitWithInvalidGeneSequence {
    void (^expressionBlock)() = ^{
        __unused Chromosome *testChromosome = [[Chromosome alloc] initWithGeneSequence:@"" domain:@"abcd"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitWithNilDomain {
    void (^expressionBlock)() = ^{
        __unused Chromosome *testChromosome = [[Chromosome alloc] initWithGeneSequence:@"abcd" domain:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitWithInvalidDomain {
    void (^expressionBlock)() = ^{
        __unused Chromosome *testChromosome = [[Chromosome alloc] initWithGeneSequence:@"abcd" domain:@""];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithInvalidLength {
    void (^expressionBlock)() = ^{
        __unused Chromosome *testChromosome = [[Chromosome alloc] initRandomChromosomeWithLength:0 domain:@"abcd"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithNilDomain {
    void (^expressionBlock)() = ^{
        __unused Chromosome *testChromosome = [[Chromosome alloc] initRandomChromosomeWithLength:5 domain:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithInvalidDomain {
    void (^expressionBlock)() = ^{
        __unused Chromosome *testChromosome = [[Chromosome alloc] initRandomChromosomeWithLength:5 domain:@""];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

@end
