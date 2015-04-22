//
//  RandomTests.m
//  Evolve
//
//  Created by Mike on 4/20/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Random.h"

static NSInteger const kRandomTestIterations = 10000;

@interface RandomTests : XCTestCase

@end

@implementation RandomTests

- (void)testRandomInteger {
    NSInteger min = -1234;
    NSInteger max = 1234;

    for (size_t i = 0; i < kRandomTestIterations; i++) {
        NSInteger random = [Random randomIntegerFromMin:min toMax:max];

        XCTAssert(random >= min);
        XCTAssert(random <= max);
    }
}

- (void)testRandomIntegerPositiveRange {
    NSInteger min = 1234;
    NSInteger max = 5678;

    for (size_t i = 0; i < kRandomTestIterations; i++) {
        NSInteger random = [Random randomIntegerFromMin:min toMax:max];

        XCTAssert(random >= min);
        XCTAssert(random <= max);
    }
}

- (void)testRandomIntegerNegativeRange {
    NSInteger min = -5678;
    NSInteger max = -1234;

    for (size_t i = 0; i < kRandomTestIterations; i++) {
        NSInteger random = [Random randomIntegerFromMin:min toMax:max];

        XCTAssert(random >= min);
        XCTAssert(random <= max);
    }
}

- (void)testRandomGeneSequence {
    for (NSInteger i = 0; i < kRandomTestIterations; i++) {
        NSInteger randomLength = [Random randomIntegerFromMin:1 toMax:100];
        NSString *testDomain = @"abcdefgHIJKLMNOP 67890";
        NSString *randomGeneSequence = [Random randomGeneSequenceWithLength:randomLength domain:testDomain];

        XCTAssertEqual(randomGeneSequence.length, randomLength);

        for (NSInteger index = 0; index < randomGeneSequence.length; index++) {
            NSString *character = [randomGeneSequence substringWithRange:NSMakeRange(index, 1)];
            BOOL randomSequenceContainsCharacter = [randomGeneSequence rangeOfString:character].location != NSNotFound;

            XCTAssert(randomSequenceContainsCharacter);
        }
    }
}

- (void)testRandomGeneSequenceInvalidLength {
    void (^expressionBlock)() = ^{
        [Random randomGeneSequenceWithLength:0 domain:@"1234"];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testRandomGeneSequenceNilDomain {
    void (^expressionBlock)() = ^{
        [Random randomGeneSequenceWithLength:5 domain:nil];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

- (void)testRandomGeneSequenceInvalidDomain {
    void (^expressionBlock)() = ^{
        [Random randomGeneSequenceWithLength:5 domain:@""];
    };

    XCTAssertThrowsSpecificNamed(expressionBlock(), NSException, NSInternalInconsistencyException);
}

@end
