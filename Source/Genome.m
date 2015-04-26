//
//  Genome.m
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "Genome.h"
#import "Random.h"


@implementation Genome

#pragma mark - Initializers

- (instancetype)initRandomGenomeWithLength:(NSUInteger)length domain:(NSString *)domain {
    return [self initWithGeneSequence:[Random randomGeneSequenceWithLength:length domain:domain] domain:domain];
}

- (instancetype)initWithGeneSequence:(NSString *)geneSequence domain:(NSString *)domain {
    self = [super init];

    NSParameterAssert(geneSequence);
    NSParameterAssert(geneSequence.length >= kMinimumGeneSequenceLength);
    NSParameterAssert(domain);
    NSParameterAssert(domain.length > 0);

    self.sequence = geneSequence;
    self.domain = domain;

    return self;
}


#pragma mark - Mutation

- (void)handleMutationWithRate:(CGFloat)mutationRate {
    // Take the decimal value and convert it to an integer - which we expect to be between
    // 0 and 100, for easy probability calculation.
    NSInteger convertedMutationRate = (NSInteger)round(mutationRate * 100);

    // Each gene in the genome has some random predetermined chance to mutate to some other gene.
    // Here is where we apply this concept... First we iterate through all the genes in the sequence.
    for (NSInteger geneIndex = 0; geneIndex < self.sequence.length; geneIndex++) {

        // Determine if we should mutate this or not.
        NSInteger random = [Random randomIntegerFromMin:1 toMax:100];
        BOOL shouldMutateGene = random <= convertedMutationRate;

        // If we should, get a random character from the set of possible characters for this genome and
        // replace the current character with it.
        if (shouldMutateGene) {
            BOOL keepSearching = YES;
            unichar oldGene = [self.sequence characterAtIndex:geneIndex];

            // We need to keep trying until we actually get a distinct random new gene.
            while (keepSearching) {
                NSInteger randomIndex = [Random randomIntegerFromMin:0 toMax:self.domain.length - 1];
                unichar newGene = [self.domain characterAtIndex:randomIndex];

                if (newGene != oldGene) {
                    NSString *replacementGene = [NSString stringWithFormat:@"%C", newGene];
                    self.sequence = [self.sequence stringByReplacingCharactersInRange:NSMakeRange(geneIndex, 1) withString:replacementGene];

                    keepSearching = NO;
                }
            }
        }
    }
}

#pragma mark - Debugging

- (NSString *)debugDescription {
    return @{
             @"domain": self.domain,
             @"geneSequence": self.sequence
             }.description;
}

@end
