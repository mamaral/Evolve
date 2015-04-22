//
//  Chromosome.m
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "Chromosome.h"
#import "Random.h"

@implementation Chromosome

#pragma mark - Initializers

- (instancetype)initRandomChromosomeWithLength:(NSUInteger)length domain:(NSString *)domain {
    return [self initWithGeneSequence:[Random randomGeneSequenceWithLength:length domain:domain] domain:domain];
}

- (instancetype)initWithGeneSequence:(NSString *)geneSequence domain:(NSString *)domain {
    self = [super init];

    if (!self) {
        return nil;
    }

    NSParameterAssert(geneSequence);
    NSParameterAssert(geneSequence.length > 0);
    NSParameterAssert(domain);
    NSParameterAssert(domain.length > 0);

    self.geneSequence = geneSequence;
    self.domain = domain;

    return self;
}


#pragma mark - Mutation

- (void)handleMutationWithRate:(CGFloat)mutationRate {
    // Take the decimal value and convert it to an integer - which we expect to be between
    // 0 and 100, for easy probability calculation.
    NSInteger convertedMutationRate = (NSInteger)round(mutationRate * 100);

    // Each gene in the chromosome has some random predetermined chance to mutate to some other gene.
    // Here is where we apply this concept... First we iterate through all the genes in the sequence.
    for (NSInteger geneIndex = 0; geneIndex < self.geneSequence.length; geneIndex++) {

        // Determine if we should mutate this or not.
        NSInteger random = [Random randomIntegerFromMin:1 toMax:100];
        BOOL shouldMutateChar = random < convertedMutationRate;

        // If we should, get a random character from the set of possible characters for this genome and
        // replace the current character with it. NOTE: There is a chance the newly selected random character
        // happens to be the same as the current character, which we are currently leaving as a possibility.
        if (shouldMutateChar) {
            NSInteger randomIndex = [Random randomIntegerFromMin:0 toMax:self.domain.length - 1];
            unichar randomCharInSet = [self.domain characterAtIndex:randomIndex];
            NSString *replacementString = [NSString stringWithFormat:@"%C", randomCharInSet];

            self.geneSequence = [self.geneSequence stringByReplacingCharactersInRange:NSMakeRange(geneIndex, 1) withString:replacementString];
        }
    }
}

#pragma mark - Debugging

- (NSString *)debugDescription {
    return @{
             @"domain": self.domain,
             @"geneSequence": self.geneSequence
             }.description;
}

@end
