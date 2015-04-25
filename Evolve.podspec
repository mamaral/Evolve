Pod::Spec.new do |s|

  s.name         = "Evolve"
  s.version      = "0.4"
  s.summary      = "An Objective-C evolution simulation engine."
  s.homepage     = "https://github.com/mamaral/Evolve"
  s.license      = "MIT"
  s.author       = { "Mike Amaral" => "mike.amaral36@gmail.com" }
  s.social_media_url   = "http://twitter.com/MikeAmaral"
  s.platform     = :ios
  s.source       = { :git => "https://github.com/mamaral/Evolve.git", :tag => "v0.4" }
  s.source_files  = "Source/EvolutionManager.{h,m}", "Source/Population.{h,m}", "Source/Organism.{h,m}", "Source/Genome.{h,m}", "Source/Random.{h,m}"
  s.requires_arc = true

end
