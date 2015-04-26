//
//  GenomeTests.m
//  Evolve
//
//  Created by Mike on 4/20/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Genome.h"
#import "Random.h"

static NSInteger const kGenomeTestIterations = 10000;

@interface GenomeTests : XCTestCase

@end

@implementation GenomeTests

- (void)testInitWithGeneSequenceAndDomain {
    NSString *entireDomain = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";
    
    for (NSInteger i = 0; i < kGenomeTestIterations; i++) {
        NSInteger randomSequenceLength = [Random randomIntegerFromMin:4 toMax:50];
        NSInteger randomDomainLength = [Random randomIntegerFromMin:1 toMax:25];
        NSString *randomDomain = [Random randomGeneSequenceWithLength:randomDomainLength domain:entireDomain];
        NSString *randomGeneSequence = [Random randomGeneSequenceWithLength:randomSequenceLength domain:randomDomain];

        Genome *genome = [[Genome alloc] initWithGeneSequence:randomGeneSequence domain:randomDomain];

        XCTAssertNotNil(genome);
        XCTAssert([genome.sequence isEqualToString:randomGeneSequence]);
        XCTAssert([genome.domain isEqualToString:randomDomain]);
    }
}

- (void)testInitRandomWithLengthAndDomain {
    NSString *entireDomain = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789";

    for (NSInteger i = 0; i < kGenomeTestIterations; i++) {
        NSInteger randomSequenceLength = [Random randomIntegerFromMin:4 toMax:50];
        NSInteger randomDomainLength = [Random randomIntegerFromMin:1 toMax:25];
        NSString *randomDomain = [Random randomGeneSequenceWithLength:randomDomainLength domain:entireDomain];

        Genome *genome = [[Genome alloc] initRandomGenomeWithLength:randomSequenceLength domain:randomDomain];

        XCTAssertNotNil(genome);
        XCTAssertEqual(genome.sequence.length, randomSequenceLength);
        XCTAssert([genome.domain isEqualToString:randomDomain]);
    }
}

- (void)testInitWithNilGeneSequence {
    void (^expressionBlock)() = ^{
        __unused Genome *testGenome = [[Genome alloc] initWithGeneSequence:nil domain:@"abcd"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitWithInvalidGeneSequence {
    void (^expressionBlock)() = ^{
        __unused Genome *testGenome = [[Genome alloc] initWithGeneSequence:@"" domain:@"abcd"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitWithNilDomain {
    void (^expressionBlock)() = ^{
        __unused Genome *testGenome = [[Genome alloc] initWithGeneSequence:@"abcd" domain:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitWithInvalidDomain {
    void (^expressionBlock)() = ^{
        __unused Genome *testGenome = [[Genome alloc] initWithGeneSequence:@"abcd" domain:@""];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithInvalidLength {
    void (^expressionBlock)() = ^{
        __unused Genome *testGenome = [[Genome alloc] initRandomGenomeWithLength:0 domain:@"abcd"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithNilDomain {
    void (^expressionBlock)() = ^{
        __unused Genome *testGenome = [[Genome alloc] initRandomGenomeWithLength:5 domain:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testInitRandomWithInvalidDomain {
    void (^expressionBlock)() = ^{
        __unused Genome *testGenome = [[Genome alloc] initRandomGenomeWithLength:5 domain:@""];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testHandleMutationGuarenteed {
    // With a 100% mutation rate a gene should never be the same after mutation.
    NSString *testDomain = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    Genome *testGenome = [[Genome alloc] initRandomGenomeWithLength:4 domain:testDomain];
    
    for (NSInteger i = 0; i < kGenomeTestIterations; i++) {
        NSString *originalGeneSequence = testGenome.sequence;

        [testGenome handleMutationWithRate:1.0];

        NSString *newGeneSequence = testGenome.sequence;

        XCTAssertFalse([newGeneSequence isEqualToString:originalGeneSequence]);
    }
}

- (void)testHandleMutationShouldNotHappen {
    // With a 0% mutation rate a gene should be the same after mutation.
    NSString *testDomain = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    Genome *testGenome = [[Genome alloc] initRandomGenomeWithLength:4 domain:testDomain];

    for (NSInteger i = 0; i < kGenomeTestIterations; i++) {
        NSString *originalGeneSequence = testGenome.sequence;

        [testGenome handleMutationWithRate:0.0];

        NSString *newGeneSequence = testGenome.sequence;

        XCTAssertTrue([newGeneSequence isEqualToString:originalGeneSequence]);
    }
}

- (void)testDebugDescription {
    NSString *testDomain = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    Genome *testGenome = [[Genome alloc] initRandomGenomeWithLength:4 domain:testDomain];

    XCTAssertNotNil([testGenome debugDescription]);
}

@end
