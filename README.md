##Evolve

A customizable evolution simulation engine written in Objective-C.

[![License](https://img.shields.io/cocoapods/l/Evolve.svg)](http://doge.mit-license.org) [![Build Status](https://img.shields.io/travis/mamaral/Evolve.svg)](https://travis-ci.org/mamaral/Evolve/) ![Badge w/ Version](https://img.shields.io/cocoapods/v/Evolve.svg)


## Installation

Available via [CocoaPods](http://cocoapods.org/?q=Evolve)

```ruby
pod ‘Evolve’
```

## Classic Example: [The Weasel Program](http://en.wikipedia.org/wiki/Weasel_program)
![Weasel Program](Screenshots/methinks.gif)

> I don't know who it was first pointed out that, given enough time, a monkey bashing away at random on a typewriter could produce all the works of Shakespeare. The operative phrase is, of course, given enough time. Let us limit the task facing our monkey somewhat. Suppose that he has to produce, not the complete works of Shakespeare but just the short sentence 'Methinks it is like a weasel', and we shall make it relatively easy by giving him a typewriter with a restricted keyboard, one with just the 26 (capital) letters, and a space bar. How long will he take to write this one little sentence? - Richard Dawkins


***Initializing the Population***

The `EvolutionManager` handles all of the simulation mechanics, and is initialized with a starting `Population` object. A `Population` can be seeded with a group of `Organism` objects, or as is the case with this example, *randomly generated* given specific parameters:

- `size` is the number of organisms that are alive in any given generation, and will remain constant throughout the simulation.
- `geneSequenceLength` is the length of each organism's gene sequence, represented as an `NSString`.
- `chromosomeDomain` is an `NSString` that represents all possible characters that can be used in the organism's gene sequence. For example, if you wanted an organism's genetic code to be represented as a binary string, you would set the domain to `@"01"`.

In this example, we create our population with 50 organisms, a gene sequence length to be the length of the target string, `METHINKS IT IS LIKE A WEASEL`, and the domain includes all 26 capital letters as well as the space character. We then create our evolution manager with this population, and set ourself as the delegate, ensuring we're conforming to the `<EvolutionDelegate>` protocol. In our view controller's header:

```objective-c
#import <UIKit/UIKit.h>
#import "EvolutionManager.h"

@interface WeaselProgramViewController : UIViewController <EvolutionDelegate>

@property (nonatomic, strong) EvolutionManager *evolutionManager;

@end
```

Then when we want to start the simulation:

```objective-c
static NSString * const kTargetString = @"METHINKS IT IS LIKE A WEASEL";
static NSString * const kTargetDomain = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ ";

Population *startingPopulation = [[Population alloc] initRandomPopulationWithSize:50 geneSequenceLength:kTargetString.length chromosomeDomain:kTargetDomain];

self.evolutionManager = [[EvolutionManager alloc] initWithPopulation:startingPopulation];
self.evolutionManager.delegate = self;
```


## Community

- If you want to contribute, open a pull request. Please do your best to keep the style/formatting consistent with the current project and MAKE SURE TO ADD TESTS!

- If you have questions, feature requests, etc., I would prefer if you created an issue rather than email me directly.


## License

This project is made available under the MIT license. See LICENSE.txt for details.
