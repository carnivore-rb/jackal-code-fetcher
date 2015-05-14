require 'git'
require 'jackal-code-fetcher'

describe Jackal::CodeFetcher::GitHub do
  ASSET_OWNER = 'jackal'
  ASSET_NAME  = 'test-repo'
  # initial commit :)
  COMMIT_SHA  = '2b3aa2cd43223498030daad2732a3e4d3d052cf5'

  before do
    @runner = run_setup(:test)
    @config = Carnivore::Config.data.get(:jackal)
    @working_dir = @config.get(:code_fetcher, :config, :working_directory)
    @obj_store   = @config.get(:assets, :connection, :credentials, :object_store_root)
  end

  after do
    @runner.terminate if @runner && @runner.alive?
    FileUtils.rm_rf(@working_dir)
    FileUtils.rm_rf(@obj_store)
  end

  let(:supervisor) do
    Carnivore::Supervisor.supervisor[:jackal_code_fetcher_input]
  end

  describe 'jackal code fetcher' do
    it 'fetches repo and stores as local asset' do
      supervisor.transmit(payload)
      repo_path = File.join(@working_dir, ASSET_OWNER, ASSET_NAME)

      # Ensure repository / archive exist
      exists_fn = lambda do
        bucket = @config.get(:assets, :bucket)
        archive_path = Dir[File.join(@obj_store, bucket, '*.zip')].first
        [repo_path, archive_path].all? { |f| f && File.exists?(f) }
      end
      source_wait(1, &exists_fn)
      exists_fn.call.must_equal true

      # and that it contains proper data
      repo = Git.open(repo_path)
      repo.checkout(COMMIT_SHA)
      commit = repo.log.first
      commit.message.must_equal 'Initial commit'
      commit.sha.must_equal COMMIT_SHA
    end
  end

  private

  def payload(type = :commit)
    h = {:code_fetcher => {
           :info => {
             :url   => 'https://github.com/carnivore-rb/jackal-code-fetcher.git',
             :owner => ASSET_OWNER,
             :name  => ASSET_NAME,
             :commit_sha => COMMIT_SHA }}}
    Jackal::Utils.new_payload('test', h)
  end

end
