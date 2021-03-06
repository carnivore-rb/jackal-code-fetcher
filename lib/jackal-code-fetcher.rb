require 'jackal'

module Jackal
  module CodeFetcher
    autoload :GitHub, 'jackal-code-fetcher/git_hub'
  end
end

require 'jackal-code-fetcher/version'

Jackal.service(
  :code_fetcher,
  :description => 'Fetch code from remote source',
  :configuration => {
    :github__access_token => {
      :type => :string,
      :description => 'GitHub access token to use for repository access'
    },
    :working_directory => {
      :type => :string,
      :description => 'Host working directory',
      :public => false
    }
  }
)
