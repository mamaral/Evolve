//
//  Population.h
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organism.h"
#import "Genome.h"

@interface Population : NSObject

@property (nonatomic, strong) NSArray *organisms;

- (instancetype)initRandomPopulationWithSize:(NSUInteger)size geneSequenceLength:(NSUInteger)geneSequenceLength genomeDomain:(NSString *)domain;
- (instancetype)initWithOrganisms:(NSArray *)organisms;

@end

