//
//  WeaselProgramViewController.m
//  Evolve
//
//  Created by Mike on 4/18/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "WeaselProgramViewController.h"

static NSString * const kTargetString = @"METHINKS IT IS LIKE A WEASEL";
static NSString * const kTargetDomain = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ ";
static NSTimeInterval const kTimeIntervalPerGeneration = 0.05;

@interface WeaselProgramViewController ()

@end

@implementation WeaselProgramViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Set up the demo UI.
    self.title = @"The Weasel Program";

    self.fittestOrganismLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
    self.fittestOrganismLabel.center = self.view.center;
    self.fittestOrganismLabel.textAlignment = NSTextAlignmentCenter;
    self.fittestOrganismLabel.numberOfLines = 2;
    [self.view addSubview:self.fittestOrganismLabel];

    // Add a nav button to trigger starting the simulation.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startSimulation)];
}


#pragma mark - Starting the simulation

- (void)startSimulation {
    // Stop the timer if it's already running.
    if (self.timer.isValid) {
        [self.timer invalidate];
    }

    // Reset the UI for the start of the simulation.
    self.fittestOrganismLabel.textColor = [UIColor blackColor];

    // Reset our population and start.
    [self configurePopulationAndStart];
}


#pragma mark - Population initialization

- (void)configurePopulationAndStart {
    // Create our population - which will be 50 organisms in size, will have a genome the length of our target string,
    // and will have the domain defined above, which includes all capital letters and the space character.
    Population *startingPopulation = [[Population alloc] initRandomPopulationWithSize:50 geneSequenceLength:kTargetString.length genomeDomain:kTargetDomain];

    // Create our evolution manager with the starting population and set ourself as the delegate to recieve the appropriate callbacks.
    self.evolutionManager = [[EvolutionManager alloc] initWithPopulation:startingPopulation];
    self.evolutionManager.delegate = self;

    // Start the simulation timer.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimeIntervalPerGeneration target:self selector:@selector(continueWithNextGeneration) userInfo:nil repeats:YES];
}

- (void)continueWithNextGeneration {
    [self evaluateFitnessForPopulation:self.evolutionManager.population];
    [self.evolutionManager processNextGeneration];
}

- (void)evaluateFitnessForPopulation:(Population *)population {
    // Pass all the organisms through our fitness function.
    for (Organism *organism in population.organisms) {
        organism.fitness = [self fitnessFunctionForOrganism:organism];
    }
}

- (NSInteger)fitnessFunctionForOrganism:(Organism *)organism {
    // Get the genome string from this organism.
    NSString *genomeString = organism.genome.sequence;

    // We're going to keep track of the number of characters in the genome that
    // match our target string at the correct index. Each match increases the "fitness"
    // of this organism.
    NSInteger correctCharacters = 0;

    for (NSInteger charIndex = 0; charIndex < organism.genome.sequence.length; charIndex++) {
        if ([genomeString characterAtIndex:charIndex] == [kTargetString characterAtIndex:charIndex]) {
            correctCharacters++;
        }
    }

    return correctCharacters;
}


#pragma mark - Evolution delegate

- (void)population:(Population *)population didCompetedGeneration:(NSUInteger)generation fittestOrganisms:(NSArray *)fittestOrganisms offspring:(NSArray *)offspring completeNextGeneration:(NSArray *)nextGeneration {
    // Get the fittest organism for this generation, which will be the first object in the fittest organisms array.
    Organism *fittestOrganism = [fittestOrganisms firstObject];

    // Get the string representation of the genome.
    NSString *genomeString = fittestOrganism.genome.sequence;

    // If it equals our target string, we can end the simulation.
    if ([genomeString isEqualToString:kTargetString]) {
        self.fittestOrganismLabel.text = [NSString stringWithFormat:@"Target organism acheived in generation %ld:\n%@", generation, genomeString];
        self.fittestOrganismLabel.textColor = [UIColor redColor];

        [self.timer invalidate];
    }

    // Otherwise just print out the generation number and the genome string for a visual representation of this generation.
    else {
        self.fittestOrganismLabel.text = [NSString stringWithFormat:@"Fittest organism for generation %ld:\n%@", generation, genomeString];
    }
}

@end
