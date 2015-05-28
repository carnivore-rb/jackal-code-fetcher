$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'jackal-code-fetcher/version'
Gem::Specification.new do |s|
  s.name = 'jackal-code-fetcher'
  s.version = Jackal::CodeFetcher::VERSION.version
  s.summary = 'Message processing helper'
  s.author = 'Chris Roberts'
  s.email = 'code@chrisroberts.org'
  s.homepage = 'https://github.com/carnivore-rb/jackal-code-fetcher'
  s.description = 'Code fetching helper'
  s.require_path = 'lib'
  s.license = 'Apache 2.0'
  s.add_dependency 'jackal'
  s.add_dependency 'git'

  s.add_development_dependency 'carnivore-actor'
  s.add_development_dependency 'jackal-assets'

  s.files = Dir['lib/**/*'] + %w(jackal-code-fetcher.gemspec README.md CHANGELOG.md CONTRIBUTING.md LICENSE)
end
