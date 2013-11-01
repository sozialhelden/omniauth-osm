# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth-osm/version"

Gem::Specification.new do |gem|
  gem.name        = 'omniauth-osm'
  gem.version     = OmniAuth::Osm::VERSION
  gem.authors     = ["Christoph Bünte"]
  gem.email       = 'christoph@sozialhelden.de'
  gem.homepage    = 'https://github.com/sozialhelden/omniauth-osm'
  gem.description = %q{OpenStreetMap strategy for OmniAuth 1.0a}
  gem.summary     = %q{OpenStreetMap strategy for OmniAuth 1.0a}
  gem.license     = 'MIT'

  gem.rubyforge_project = "omniauth-osm"

  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ['lib']

  gem.add_runtime_dependency "omniauth-oauth", "~> 1.0"

  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'simplecov', '~> 0.5'
  gem.add_development_dependency 'webmock', '~> 1.7'


end