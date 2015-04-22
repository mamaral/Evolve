//
//  Chromosome.h
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Chromosome : NSObject

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *geneSequence;

- (instancetype)initWithGeneSequence:(NSString *)geneSequence domain:(NSString *)domain;
- (instancetype)initRandomChromosomeWithLength:(NSUInteger)length domain:(NSString *)domain;

- (void)handleMutationWithRate:(CGFloat)mutationRate;

@end
