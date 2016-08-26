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

@class EvolutionManager;

@protocol EvolutionDelegate <NSObject>

@required
- (void)evolutionManager:(EvolutionManager *)evolutionManager didCompetedGeneration:(NSUInteger)generation fittestOrganism:(Organism *)fittestOrganism offspring:(NSArray *)offspring nextGeneration:(NSArray *)nextGeneration;

@end

@interface EvolutionManager : NSObject

@property (nonatomic, weak) id <EvolutionDelegate> delegate;

@property (nonatomic, strong) Population *population;

@property (nonatomic) NSUInteger currentGeneration;

@property (nonatomic) enum CrossoverMethod crossoverMethod;
@property (nonatomic) NSUInteger tournamentSize;
@property (nonatomic) CGFloat elitismPercentage;
@property (nonatomic) CGFloat mutationRate;

- (instancetype)initWithPopulation:(Population *)population;

- (void)proceedWithSelectionAndBreeding;

@end
