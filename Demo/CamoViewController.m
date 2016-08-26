//
//  CamoViewoController.m
//  Evolve
//
//  Created by Mike on 8/26/16.
//  Copyright © 2016 Mike Amaral. All rights reserved.
//

#import "CamoViewController.h"
#import "UIColor+Utils.h"

static NSUInteger const kPopulationSize = 150;
static NSString * const kGenomeDomain = @"ABCDEF1234567890";

@interface CamoViewController ()

@property (nonatomic, strong) EvolutionManager *evolutionManager;
@property (nonatomic, strong) NSMutableArray *views;

@end

@implementation CamoViewController

- (instancetype)init {
    self = [super init];

    if (!self) {
        return nil;
    }

    self.views = [NSMutableArray arrayWithCapacity:kPopulationSize];

    for (NSUInteger i = 0; i < kPopulationSize; i++) {
        UIImageView *newView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"lizard"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        newView.tintColor = [UIColor blackColor];
        [self.views addObject:newView];
    }

    Population *startingPopulation = [[Population alloc] initRandomPopulationWithSize:self.views.count geneSequenceLength:20 genomeDomain:kGenomeDomain];

    self.evolutionManager = [[EvolutionManager alloc] initWithPopulation:startingPopulation];
    self.evolutionManager.delegate = self;
    self.evolutionManager.mutationRate = .01;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(start)];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.view.backgroundColor = [UIColor randomColor];

    for (UIView *view in self.views) {
        [self.view addSubview:view];
    }

}

- (void)start {
    [self.evolutionManager proceedWithSelectionAndBreeding];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    NSUInteger currentColumn = 0;
    CGFloat xOrigin = 5;
    CGFloat yOrigin = 5;
    CGFloat size = (CGRectGetWidth(self.view.frame) - ((10.0 + 1) * 5)) / 10.0;
    CGFloat offset = size + 5;

    for (UIView *subview in self.views) {
        subview.frame = CGRectMake(xOrigin, yOrigin, size, size);

        if (currentColumn == 10.0 - 1) {
            currentColumn = 0;

            xOrigin = 5;
            yOrigin += offset;
        }

        else {
            currentColumn++;

            xOrigin += offset;
        }
    }
}


#pragma mark - Evolution delegate

- (void)evolutionManager:(EvolutionManager *)evolutionManager didCompetedGeneration:(NSUInteger)generation fittestOrganism:(Organism *)fittestOrganism offspring:(NSArray *)offspring nextGeneration:(NSArray *)nextGeneration {

    for (NSUInteger i = 0; i < nextGeneration.count; i++) {
        Organism *organism = nextGeneration[i];
        UIView *organismView = self.views[i];
        NSString *genomeString = [organism.genome.sequence substringToIndex:6];
        UIColor *newColor = [UIColor colorFromHexString:genomeString];
        organismView.tintColor = newColor;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self evaluateFitnessForPopulation];
        [self.evolutionManager proceedWithSelectionAndBreeding];
    });
}

- (void)evaluateFitnessForPopulation {
    NSArray *organisms = self.evolutionManager.population.organisms;

    for (NSUInteger i = 0; i < organisms.count; i++) {
        Organism *organism = organisms[i];
        NSString *genomeString = [organism.genome.sequence substringToIndex:6];
        UIColor *organismColor = [UIColor colorFromHexString:genomeString];
        UIColor *environmentColor = self.view.backgroundColor;
        CGFloat camoLevel = -1 * [organismColor distanceFromColor:environmentColor];
        organism.fitness = roundf(camoLevel * 100.0);
    }
}

@end
