##Evolve

An Evolution Simulation Engine written in Objective-C.

[![License](https://img.shields.io/cocoapods/l/Evolve.svg)](http://doge.mit-license.org) [![Build Status](https://img.shields.io/travis/mamaral/Evolve.svg)](https://travis-ci.org/mamaral/Evolve/) ![Badge w/ Version](https://img.shields.io/cocoapods/v/Evolve.svg)



## Installation

Available via [CocoaPods](http://cocoapods.org/?q=Evolve)

```ruby
pod ‘Evolve’
```


## Classic Example: [The Weasel Program](http://en.wikipedia.org/wiki/Weasel_program)
![Weasel Program](Screenshots/methinks.gif)

> I don't know who it was first pointed out that, given enough time, a monkey bashing away at random on a typewriter could produce all the works of Shakespeare. The operative phrase is, of course, given enough time. Let us limit the task facing our monkey somewhat. Suppose that he has to produce, not the complete works of Shakespeare but just the short sentence 'Methinks it is like a weasel', and we shall make it relatively easy by giving him a typewriter with a restricted keyboard, one with just the 26 (capital) letters, and a space bar. How long will he take to write this one little sentence? - Richard Dawkins


# ***Initializing the Population***

The `EvolutionManager` handles all of the simulation mechanics, and is initialized with a starting `Population` object. A `Population` can be seeded with a group of `Organism` objects, or as is the case with this example, *randomly generated* given specific parameters:

- `size` is the number of organisms that are alive in any given generation, and will remain constant throughout the simulation.
- `geneSequenceLength` is the length of each organism's gene sequence, represented as an `NSString`.
- `genomeDomain` is an `NSString` that represents all possible characters that can be used in the organism's gene sequence. For example, if you wanted an organism's genetic code to be represented as a 5-digit binary string, you would set the domain to `@"01"` and the length to `5`. A randomly generated gene sequence from this type of organism might look like `01001`.

In this example, we create our population with 50 organisms, a gene sequence length to be the length of the target string, `METHINKS IT IS LIKE A WEASEL`, and the domain includes all 26 capital letters as well as the space character. We then create our evolution manager with this population, and set ourself as the delegate, ensuring we're conforming to the `<EvolutionDelegate>` protocol.

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
    for (Organism *organism in self.evolutionManager.population.organisms) {
        NSString *genomeString = organism.genome.sequence;
        NSInteger geneSequenceLength = organism.genome.sequence.length;
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
[self.evolutionManager proceedWithSelection];
```

This algorithm utilizes a [***tournament selection***](http://en.wikipedia.org/wiki/Tournament_selection) method for choosing organisms to breed. Subsets of the population are chosen at random to *compete* for the chance to breed, with the fittest organism of this subset being selected as a parent. These organisms are not removed from the pool of competitors, and thus it is possible for an organism to parent multiple offspring.

The size of each tournament can be customized by setting the `tournamentSize` property on the `EvolutionManager`. Experiment with different values here to see how this effects your population. Having a tournament size of `1` is essentially random selection, which would likely lead to slow improvements in overall population fitness generation-over-generation, whereas having a high tournament size increases the mating chances of the most fit organisms and thus decreases mating chances for less-fit organisms, resulting in less diversity and potentially [premature convergence](http://en.wikipedia.org/wiki/Premature_convergence).

During the selection process the population is sorted based on each individual's fitness level, and some number of the most fit organisms are selected to live on to the next generation unchanged. This process is known as [***elitism***](http://en.wikipedia.org/wiki/Genetic_algorithm#Elitism). By setting the `elitismPercentage` property on the `EvolutionManager` you're able to customize the percentage of organisms from the current generation that will survive and continue into the next. This property can be set to any `CGFloat` value between 0.0 (inclusive) to 1.0 (non-inclusive), and indicates the percentage of the total population `n` that survives through to generation `n + 1`.

>***Example:*** If you have a population of 100 organisms, and you set the `elitismPercentage` to `0.1`, this will result in 10 organisms from generation `0` being included in the population for the generation `1`, as well as leave room for 90 offspring to be generated, resulting in the constant population size of 100 organisms. If the `elitismPercentage ` value is not set, the default value of `0.10` is used, resulting in approximately 10% of the population being selected to live on for another generation. This ensures some level of protection against degredation in overall population fitness, but can lead to premature convergence if set too high.

# *Crossover and Mutation*

Once the selection process is complete, organisms are chosen at random from the pool of potential parents and are paired to mate, producing a child organism with the same genetic characteristics as both parents, meaning the `length` and `domain` of the genome remain the same. This algorithm simulates sexual reproduction, as opposed to asexual reproduction, which means that offspring are always generated from two distinct parents. Although we've selected some of the fittest organisms to reproduce during this process, ***not all organisms in this pool are guarenteed to produce offspring.*** The parental selection process is random, so some lucky organisms might parent multiple offspring, while other poor saps might not get any chance.

When the two parents are randomly selected from the pool, their genes are combined using the [One-point crossover](http://en.wikipedia.org/wiki/Crossover_(genetic_algorithm)#One-point_crossover) technique. A random index is chosen between `0` and `length - 1` of the gene sequence, both genomes are copied, "split" at this index, and recombined to form the child's genetic code.

>***Example:*** If the domain is defined as `@"AB"`, with the first parent's gene sequence as `AAAAA` and the second's as `BBBBB`, if the randomly chosen index was `2`, the first parent's contribution would be `AA`, and the second parent's contribution would be `BBB`, resulting in the child's genetic sequence of `AABBB`.

After the crossover process is complete, every gene in the offspring's genetic sequence has a chance to [***mutate***](http://en.wikipedia.org/wiki/Mutation_(genetic_algorithm)). This algorithm utilizes a uniform mutation strategy, meaning that if by chance the gene does mutate, it will mutate into one of the characters defined by the domain of their genome, ***not including the current character***.

>***Example:*** If the domain is defined as `@"1234"`, and the gene at a given point in the sequence is `1`, that gene has an equal chance (1/3) of mutating into `2`, `3`, or `4`. ***Note:*** This is not to be confused with the `mutationRate` explained below! This doesn't mean that every gene has a 1/3 chance to mutate into another, but rather IF a gene mutates, it has a 1 / (n - 1) chance to end up any other gene in the domain, `n` being the length of the genome's domain.

The probability that a given gene will mutate is determined by the `mutationRate` property of the `EvolutionManager`. This property can be assigned any CGFloat greater than 0.0 and less than 1.0. Too high a mutation rate and you'll increase the randomness of the overall genetics of the population - making the preservation of any beneficial genetic traits less likely. Too low a mutation rate and you won't introduce enough diversity into the population, leading to stagnation. Experiment with this number for some interesting results! If the `mutationRate ` value is not set, the default value of `0.05` is used.

>***Example:*** With a `mutationRate` of 0.05 (5%), and a genome domain of length `5`, the probability that *any given gene* mutates is 5%, whereas the probability that *every gene* in an organism's genome mutates is .00003125% (5% * 5% * 5% * 5% * 5%).

# *Termination*

After the selection and generation of offspring, the `EvolutionManager` calls its required delegate method `evolutionManager:didCompetedGeneration:fittestOrganism:offspring:nextGeneration:`, providing details about the results of the previous generation, and the updated organisms for the next generation. You can use this information for debugging, logging, updating your UI, etc. 

You should use the `completeNextGeneration` parameter to re-evaluate the fitness of your new population, and if there is still something left to be desired you can simply call `proceedWithSelection` again to continue the process through to the next generation. If you've determined that you don't want to continue with the simulation, because some maximal fitness was reached, your population has become stagnant, etc., simply ***don't call*** `proceedWithSelection` again.

## Community

- If you want to contribute, open a pull request. Please do your best to keep the style/formatting consistent with the current project and MAKE SURE TO ADD TESTS!

- If you have questions, feature requests, etc., I would prefer if you created an issue rather than email me directly.



## License

This project is made available under the MIT license. See LICENSE.txt for details.
