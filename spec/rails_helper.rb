ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'factory_bot'
require 'rswag/specs'

ENV['TEST_ENV_NUMBER'] ||= ''

ActiveRecord::Schema.verbose = false
load File.expand_path('../db/schema.rb', __dir__)

Searchkick.client = OpenSearch::Client.new(url: ENV['OPENSEARCH_URL'] || 'http://localhost:9200',
                                           transport_options: {request: {timeout: 5}})

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = false

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before(:each) do
    tables = %w[comments posts users]
    tables.each { |t| ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{t} RESTART IDENTITY CASCADE") }

    Rails.cache.clear
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
