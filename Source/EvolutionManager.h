//
//  EvolutionManager.h
//  Evolve
//
//  Created by Mike on 4/20/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Population.h"
#import "Random.h"

@protocol EvolutionDelegate <NSObject>

@required
- (void)population:(Population *)population didCompetedGeneration:(NSUInteger)generation fittestOrganisms:(NSArray *)fittestOrganisms offspring:(NSArray *)offspring completeNextGeneration:(NSArray *)nextGeneration;

@end

@interface EvolutionManager : NSObject

@property (nonatomic) id <EvolutionDelegate> delegate;

@property (nonatomic, strong) Population *population;

@property (nonatomic) NSUInteger currentGeneration;

@property (nonatomic) CGFloat percentageOfOrganismsThatReproduce;
@property (nonatomic) CGFloat percentageOfOrganismsThatSurvive;
@property (nonatomic) CGFloat mutationRate;

- (instancetype)initWithPopulation:(Population *)population;

- (void)processNextGeneration;

@end
