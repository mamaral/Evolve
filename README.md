## Evolve

[![License](https://img.shields.io/cocoapods/l/Evolve.svg)](http://doge.mit-license.org) [![Build Status](https://img.shields.io/travis/mamaral/Evolve.svg)](https://travis-ci.org/mamaral/Evolve/) ![Badge w/ Version](https://img.shields.io/cocoapods/v/Evolve.svg) [![Coverage Status](https://coveralls.io/repos/mamaral/Evolve/badge.svg?branch=master)](https://coveralls.io/r/mamaral/Evolve?branch=master)


## What is this?

Evolve is a customizable [***evolutionary algorithm***](http://en.wikipedia.org/wiki/Evolutionary_algorithm) engine with the following features:

- [x] **Phenotype-Agnostic**. What does that mean? Good question - as far as I know I just made it up now. In a nutshell, the engine doesn't know or care what your organisms are, how they behave, what their environment is, or how their genomes effect the [***phenotype***](http://en.wikipedia.org/wiki/Phenotype) of the organism. 
- [x] **Customizable genomes**. You may want your genome to represent a color value, so you choose to define the domain of the genome to be all hex characters `0123456789ABCDEF` and the length to be `6`, so you can easily translate a gene sequence like `FF0000` to the color red. You might want your domain to be a binary string, `01` with the length `6`, like `110100`, where the first two digits represent the speed of your organism, the next two represent the strength of your organism, and the last two represent how well they're camouflaged. You define what the genome is and how it manifests itself in the wild, the possibilities are endless. Be creative!
- [x] **Constant population size** from generation to generation.
- [x] **Tournament style selection.**
- [x] **One-point or Two-point crossover.**
- [x] **Uniform mutation.**
- [x] ***Tweakable*** **simulation parameters.** Play around with some of the settable variables to see how they effect the simulation. *Tweak the dials*, make predictions and test your hypotheses in real-time!
- [x] **Flexible simulation mechanics.** The engine doesn't continue with the next generation whenever it wants, it waits for you to tell it to continue. Because of this, you can run the simulation in a for-loop running through thousands of generations almost instantly, or you can take each organism in your population and put them in a real-time interactive simulation using something like SpriteKit, making each generation take minutes, or even hours, if that's what interests you.
- [x] With all of that in mind, ***I seriously have no idea*** the extent of what can or will be created, that's what makes this so damn cool.

## Example Simulation Flow

1. Create a `Population` of `Organisms` with either of two methods:
	- ***Random*** - Create a randomized `Population`, defining the number of `Organisms`, and the characteristics of their `Genome`, and the engine creates the initial `Population` for you.
	- ***Seeded*** - Create individual `Organisms` for your initial population, defining the characteristics of their `Genome`.
2. Create an instance of `EvolutionManager` to handle running the underlying simulation, and set your appropriate `delegate` conforming to the `<EvolutionDelegate>` protocol. (Currently one required method.)
3. Assign your `EvolutionManager` the `Population` you just created.
4. Evaluate the fitness of each `Organism` in your `Population`.
5. Tell your `EvolutionManager` to proceed with the selection and breeding process.
6. Once the `EvolutionManager` has completed the selection process, it will pass back to you information about the generation it just processed, as well as an updated `Population` for the next generation.
7. If you want to continue with the simulation, repeat from step #4.


## Installation

Available via [CocoaPods](http://cocoapods.org/?q=Evolve)

```ruby
pod ‘Evolve’
```


## A Classic Example: [The Weasel Program](http://en.wikipedia.org/wiki/Weasel_program)
![Weasel Program](Screenshots/methinks.gif)

> "I don't know who it was first pointed out that, given enough time, a monkey bashing away at random on a typewriter could produce all the works of Shakespeare. The operative phrase is, of course, given enough time. Let us limit the task facing our monkey somewhat. Suppose that he has to produce, not the complete works of Shakespeare but just the short sentence 'Methinks it is like a weasel', and we shall make it relatively easy by giving him a typewriter with a restricted keyboard, one with just the 26 (capital) letters, and a space bar. How long will he take to write this one little sentence?" - Richard Dawkins

****Check out the included demo program for the full implementation of this.***


# ***Initializing the Population***

The `EvolutionManager` handles all of the simulation mechanics, and is initialized with a starting `Population` object. A `Population` can be seeded with a group of `Organism` objects, or as is the case with this example, *randomly generated* given specific parameters:

- `size` is the number of organisms that are alive in any given generation, and will remain constant throughout the simulation.
- `geneSequenceLength` is the length of each organism's gene sequence, or [***chromosome***](http://en.wikipedia.org/wiki/Chromosome_%28genetic_algorithm%29), represented as an `NSString`.
- `genomeDomain` is an `NSString` that represents all possible characters that can be used in the organism's gene sequence.

> ***Example:*** If you want an organism's genetic code to be represented as a 5-digit binary string, you would set the domain to `@"01"` and the length to `5`. A randomly generated gene sequence from this type of organism might look like `01001`, or `11100`.

In this example, we create our population with 50 organisms, a gene sequence length equal to the length of the target string, `METHINKS IT IS LIKE A WEASEL`, and the domain includes all 26 capital letters as well as the space character. We then create our evolution manager with this population, and set ourself as the delegate, ensuring we're conforming to the `<EvolutionDelegate>` protocol.

```objective-c
static NSString * const kTargetString = @"METHINKS IT IS LIKE A WEASEL";
static NSString * const kTargetDomain = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ ";

Population *startingPopulation = [[Population alloc] initRandomPopulationWithSize:50 geneSequenceLength:kTargetString.length genomeDomain:kTargetDomain];

self.evolutionManager = [[EvolutionManager alloc] initWithPopulation:startingPopulation];
self.evolutionManager.delegate = self;
```

# *Fitness*

Now that the initial population has been created, the next step is to evaluate the [***fitness***](http://en.wikipedia.org/wiki/Fitness_(biology)) of each organism. In the case of this engine, which is ultimately agnostic to the organism's phenotype and environment, ***it is the implementer's job to determine the fitness of each organism every generation.***

In the case of the Weasel Program, the fitness of each organism is represented simply as the number of characters that match the target string in the appropriate position:

|        Genetic Sequence      | Fitness  |
|------------------------------| :------: |
|`HFUR FHERYDKE DPZUNF DJQJEHA`|  **0**   |
|`MFUR FHE YDKE DPZUNFD JQJSHL`|  **5**   |
|`METHINKE FHEIS DPZUDD JQJSEL`|  **15**  |
|`METHINKS IT IS LIKE A WEASEL`|  **28**  |


This could be implemented as such:

```objective-c
- (void)evaluateFitnessForPopulation {
    NSArray *organisms = self.evolutionManager.population.organisms;

    for (Organism *organism in organisms) {
        NSString *genomeString = organism.genome.sequence;
        NSInteger geneSequenceLength = genomeString.length;
        NSInteger correctCharacters = 0;

        for (NSInteger charIndex = 0; charIndex < geneSequenceLength; charIndex++) {
            if ([genomeString characterAtIndex:charIndex] == [kTargetString characterAtIndex:charIndex]) {
                correctCharacters++;
            }
        }

        organism.fitness = correctCharacters;
    }
}
```

# *Selection*

[***Selection***](http://en.wikipedia.org/wiki/Selection_(genetic_algorithm)) is the process by which organisms are chosen for breeding the next generation. In general, the more fit an organism is, the more likely it is to be selected. Once you have established the fitness for all organisms in the population, the selection process is initiated as such:

```objective-c
[self.evolutionManager proceedWithSelectionAndBreeding];
```

This algorithm utilizes a [***tournament selection***](http://en.wikipedia.org/wiki/Tournament_selection) method for choosing organisms to breed. Subsets of the population are chosen at random to *compete* for the chance to breed, with the fittest organism of this subset being selected as a parent. The *"winners"* are not removed from the pool of competitors, and thus it is possible for an organism to parent multiple offspring.

The size of each tournament can be customized by setting the `tournamentSize` property on the `EvolutionManager`. Experiment with different values here to see how this effects your population. Having a tournament size of `1` is essentially random selection, which would likely lead to slow improvements in overall population fitness generation-over-generation as fitter organisms are given no preference during selection, whereas having a high tournament size increases the mating chances of the most fit organisms and thus decreases mating chances for less-fit organisms, resulting in less diversity and potentially [***premature convergence***](http://en.wikipedia.org/wiki/Premature_convergence).

Separate from the parent selection process, the population is sorted based on each individual's fitness level and some number of the most fit organisms are selected to live on to the next generation unchanged. This process is known as [***elitism***](http://en.wikipedia.org/wiki/Genetic_algorithm#Elitism). By setting the `elitismPercentage` property on the `EvolutionManager` you're able to customize the percentage of organisms from the current generation that will survive and continue into the next. This property can be set to any `CGFloat` value between 0.0 (inclusive) to 1.0 (non-inclusive), and indicates the percentage of the total population `n` that survives through to generation `n + 1`.

>***Example:*** If you have a population of 100 organisms, and you set the `elitismPercentage` to `0.1`, this will result in 10 organisms from generation `0` being included in the population for the generation `1`, as well as leave room for 90 offspring to be generated, resulting in the constant population size of 100 organisms. If the `elitismPercentage ` value is not set, the default value of `0.10` is used, resulting in approximately 10% of the population being selected to live on for another generation. This ensures some level of protection against degredation in overall population fitness, but can lead to premature convergence if set too high.

# *Crossover and Mutation*

This algorithm simulates sexual reproduction, as opposed to asexual reproduction, which means that offspring are always generated from two distinct parents, where the resulting child has the same genetic characteristics as both parents, meaning the `length` and `domain` of the genome remain the same. When the two parents are selected from the pool, their genes are combined using either the [***One-point crossover***](http://en.wikipedia.org/wiki/Crossover_(genetic_algorithm)#One-point_crossover) or [***Two-point crossover***](http://en.wikipedia.org/wiki/Crossover_%28genetic_algorithm%29#Two-point_crossover) techniques. Single-point crossover results in a random index being chosen between `1` and `length - 2` of the gene sequence, both genomes are copied, "split" at this index, and recombined to form the child's genetic code. The range of this index ensures that at least one gene from each parent makes it into the offspring's initial genome. Two-point crossover results in a random range being selected with the same restrictions as above, and that range is used to generate a "slice" from the genome where one parent contributes their genes from before and after the range, and the other contributes their genes from the range itself.

>***One-point Example:*** Consider a domain defined as `@"AB"`, with the first parent's gene sequence as `AAAAA` and the second's as `BBBBB`. If the randomly chosen index was `2`, the first parent's contribution would be `AA`, and the second parent's contribution would be `BBB`, resulting in the child's genetic sequence being `AABBB`.

>***Two-point example*** Consider a domain defined as `@"ABCD1234"`, with the first parent's gene sequence as `AABBCCDD` and the second's as `11223344`. If the randomly generate range was `(2,3)`, that range would be used to select `223` from the second parent's genes, as well as `AA` and `CDD` from the first parent's genes, resulting in the child's genetic sequence being `AA223CDD`.

After the crossover process is complete, every gene in the offspring's genetic sequence has a chance to [***mutate***](http://en.wikipedia.org/wiki/Mutation_(genetic_algorithm)). This algorithm utilizes a uniform mutation strategy, meaning that if by chance the gene does mutate, it will mutate into one of the characters defined by the domain of their genome, ***not including the current character***, with an equal chance to mutate into each.

>***Example:*** If the domain is defined as `@"1234"`, and the gene at a given point in the sequence is `1`, that gene has an equal chance (1/3) of mutating into `2`, `3`, or `4`. ***Note:*** This is not to be confused with the `mutationRate` explained below! This doesn't mean that every gene has a 1/3 chance to mutate into another, but rather IF a gene mutates, it has a 1 / (n - 1) chance to end up any other gene in the domain, `n` being the length of the genome's domain.

The probability that a given gene will mutate is determined by the `mutationRate` property of the `EvolutionManager`. This property can be assigned any CGFloat greater than 0.0 and less than 1.0. Too high a mutation rate and you'll increase the randomness of the overall genetics of the population - making the preservation of any beneficial genetic traits less likely. Too low of a mutation rate and you won't introduce enough diversity into the population, leading to stagnation. Experiment with this number for some interesting results! If the `mutationRate ` value is not set, the default value of `0.05` is used.

>***Example:*** With a `mutationRate` of 0.05 (5%), and a genome domain of length `5`, the probability that *any given gene* mutates is 5%, whereas the probability that *every gene* in an organism's genome mutates is .00003125% (5% * 5% * 5% * 5% * 5%).

# *Termination*

After the selection and generation of offspring, the `EvolutionManager` calls its required delegate method `evolutionManager:didCompetedGeneration:fittestOrganism:offspring:nextGeneration:`, providing details about the results of the previous generation, and the updated organisms for the next generation. You can use this information for debugging, logging, updating your UI, etc. 

The `nextGeneration` parameter represents just that, the entire next generation of your population, including offspring and elites. To continue the simulation through another generation, first re-evaluate the fitness of this new population and call `proceedWithSelectionAndBreeding` again. If you've determined that you don't want to continue with the simulation, because some maximal fitness was reached, your population has become stagnant, etc., simply ***don't call*** `proceedWithSelectionAndBreeding` again.

## Community

- If you want to contribute, open a pull request. Please do your best to keep the style/formatting consistent with the current project and MAKE SURE TO ADD TESTS!

- If you have questions, feature requests, etc., I would prefer if you created an issue rather than email me directly.



## License

This project is made available under the MIT license. See LICENSE.txt for details.
