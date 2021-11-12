require 'rake'

Gem::Specification.new do |spec|
  spec.name        = 'keep_calm_and_balance'
  spec.version     = '0.5'
  spec.date        = '2021-10-25'
  spec.license     = 'CC-BY-SA-3.0'

  spec.summary = "An action balancing game"
  spec.description = "Keep Calm & Balance is an action balancing game. It was
  created during the first Gosu Game Jam."
  spec.files       = Rake::FileList["lib/lib/**/*",
                                    "lib/media/*.png",
                                    "lib/CHANGELOG.md",
                                    "lib/keep_calm_and_balance.gemspec",
                                    "lib/keep_calm_and_balance.rb",
                                    "lib/README.md"]

  spec.author      = 'Detros'
  spec.homepage    = 'https://rasunadon.itch.io/keep-calm-and-balance'
  spec.email       = 'rasunadon@seznam.cz'
  spec.metadata = {
    "source_code_uri"   => "https://gitlab.com/rasunadon/keep-calm-and-balance",
    "bug_tracker_uri"   => "https://gitlab.com/rasunadon/keep-calm-and-balance/issues",
    "documentation_uri" => "https://gitlab.com/rasunadon/keep-calm-and-balance/blob/master/README.md",
    "changelog_uri"     => "https://gitlab.com/rasunadon/keep-calm-and-balance/blob/master/CHANGELOG.md",
    "homepage_uri"      => "https://rasunadon.itch.io/keep-calm-and-balance",
  }

  spec.platform    = Gem::Platform::RUBY
  spec.add_runtime_dependency 'gosu', '~> 0.9'
  spec.add_development_dependency 'rake', '~> 10.0'
end
