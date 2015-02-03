require 'jackal'

module Jackal
  module CodeFetcher
    autoload :GitHub, 'jackal-code-fetcher/git_hub'
  end
end

require 'jackal-code-fetcher/version'
