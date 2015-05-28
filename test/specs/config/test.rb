Configuration.new do

  jackal do
    require [
      "carnivore-actor",
      "jackal-code-fetcher"
    ]

    assets do
      connection do
        provider 'local'
        credentials do
          object_store_root '/tmp/jackal-assets'
        end
      end
      bucket 'code-fetcher'
    end

    code_fetcher do
      config do
        github do
          # Ensure this is an access token for a github account that you don't
          #   care about. We don't do anything destructive, but this token needs
          #   create / delete / comment privs on public repos. #pleasetobesecure
          access_token ENV['JACKAL_GITHUB_ACCESS_TOKEN']
        end
        working_directory '/tmp/jackal-code-fetcher'
      end

      sources do
        input do
          type 'actor'
        end

        output do
          type 'spec'
        end
      end

      callbacks [ "Jackal::CodeFetcher::GitHub" ]
    end
  end

end
