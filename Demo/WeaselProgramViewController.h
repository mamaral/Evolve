//
//  WeaselProgramViewController.h
//  Evolve
//
//  Created by Mike on 4/18/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvolutionManager.h"

@interface WeaselProgramViewController : UIViewController <EvolutionDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *fittestOrganismLabel;

@property (nonatomic, strong) EvolutionManager *evolutionManager;

@end
