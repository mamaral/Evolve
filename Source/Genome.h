//
//  Genome.h
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSUInteger const kMinimumGeneSequenceLength = 4;

@interface Genome : NSObject

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *sequence;

- (instancetype)initWithGeneSequence:(NSString *)geneSequence domain:(NSString *)domain;
- (instancetype)initRandomGenomeWithLength:(NSUInteger)length domain:(NSString *)domain;

- (void)handleMutationWithRate:(CGFloat)mutationRate;

@end
