ENV['RACK_ENV'] ||= 'test'
require 'bundler/setup'
require 'yaml'
require 'erb'
require 'active_record'
require 'factory_bot'
require 'rack/test'
db_config = YAML.safe_load(
  ERB.new(File.read(File.expand_path('../config/database.yml', __dir__))).result,
  aliases: true
)
db_settings = db_config['test']
ActiveRecord::Base.configurations = {'test' => db_settings}
Bundler.require(:default)

require_relative '../models/user'
require_relative '../models/post'
require_relative '../models/comment'
require 'opensearch-ruby'
Searchkick.client = OpenSearch::Client.new(url: ENV['OPENSEARCH_URL'] || 'http://localhost:9200',
                                           transport_options: {request: {timeout: 5}})

ENV['TEST_ENV_NUMBER'] ||= ''

ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(db_settings)
load File.expand_path('../db/schema.rb', __dir__)

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Rack::Test::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
  end
  config.before(:each) do
    tables = %w[comments posts users]
    tables.each { |t| ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{t} RESTART IDENTITY CASCADE") }

    redis_url = (ENV['REDIS_URL_BASE'] || 'redis://localhost:6379') + '/' + ENV['TEST_ENV_NUMBER'].to_s
    Redis.new(url: redis_url).flushdb

    client = Searchkick.client
    %w[users posts comments].each do |base|
      index = "#{base}_#{ENV['TEST_ENV_NUMBER'] || '0'}"
      begin
        client.indices.delete(index: index)
      rescue StandardError
        nil
      end
      client.indices.create(index: index)
    end
  end
end
