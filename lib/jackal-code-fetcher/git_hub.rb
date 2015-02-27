require 'jackal-code-fetcher'

module Jackal
  module CodeFetcher
    # GitHub code fetcher
    class GitHub < Callback

      # Setup callback
      def setup(*_)
        require 'uri'
        require 'git'
        require 'fileutils'
      end

      # @return [String] working directory
      def working_directory
        memoize(:working_directory, :direct) do
          FileUtils.mkdir_p(path = config.fetch(:working_directory, '/tmp/jackal-code-fetcher'))
          path
        end
      end

      # Determine validity of message
      #
      # @param message [Carnivore::Message]
      # @return [Truthy, Falsey]
      def valid?(message)
        super do |payload|
          payload.get(:data, :code_fetcher, :info, :commit_sha) &&
            !payload.get(:data, :code_fetcher, :asset)
        end
      end

      # Fetch code and push to asset store
      #
      # @param message [Carnivore::Message]
      def execute(message)
        failure_wrap(message) do |payload|
          store_reference(payload)
          job_completed(:code_fetcher, payload, message)
        end
      end

      # Fetch reference from GitHub repository and store compressed
      # copy in the asset store
      #
      # @param payload [Smash]
      # @return [TrueClass]
      def store_reference(payload)
        repo_dir = fetch_repository(payload)
        pack_and_store(repo_dir, payload)
      end

      # Build github URL for fetching
      #
      # @param payload [Smash]
      # @return [String]
      def github_url(payload)
        if(payload.get(:data, :code_fetcher, :info, :private))
          uri = URI.parse(payload.get(:data, :code_fetcher, :info, :url))
          uri.scheme = 'https'
          uri.user = config.fetch(:github, :access_token,
            app_config.get(:github, :access_token)
          )
          uri.to_s
        else
          payload.get(:data, :code_fetcher, :info, :url)
        end
      end

      # Generate local path
      #
      # @return [String] path
      def repository_path(payload)
        File.join(
          working_directory,
          payload.get(:data, :code_fetcher, :info, :owner),
          payload.get(:data, :code_fetcher, :info, :name)
        )
      end

      # Fetch repository from GitHub
      #
      # @param payload [Smash]
      # @return [String] path to repository directory
      def fetch_repository(payload)
        repo_path = repository_path(payload)
        if(File.directory?(repo_path))
          debug "Pulling changes to: #{repo_path}"
          repo = Git.open(repo_path)
          repo.checkout('master')
          repo.pull
          repo.fetch
        else
          debug "Initiating repository clone to: #{repo_path}"
          Git.clone(github_url(payload), repo_path)
        end
        repo_path
      end

      # Store reference in asset store
      #
      # @param path [String] local path to repository
      # @param payload [Smash]
      # @return [TrueClass]
      def pack_and_store(path, payload)
        repo = Git.open(path)
        repo.checkout(
          payload.get(:data, :code_fetcher, :info, :commit_sha)
        )
        asset_key = [
          payload.get(:data, :code_fetcher, :info, :owner),
          payload.get(:data, :code_fetcher, :info, :name),
          payload.get(:data, :code_fetcher, :info, :commit_sha)
        ].join('-') + '.zip'
        _path = File.join(working_directory, Celluloid.uuid)
        begin
          tmp_path = File.join(_path, asset_key)
          FileUtils.mkdir_p(tmp_path)
          FileUtils.cp_r(File.join(repository_path(payload), '.'), tmp_path)
          FileUtils.rm_rf(File.join(tmp_path, '.git'))
          tarball = asset_store.pack(tmp_path)
          asset_store.put(asset_key, tarball)
        ensure
          FileUtils.rm_rf(_path)
        end
        payload.set(:data, :code_fetcher, :asset, asset_key)
        true
      end

    end

  end
end
