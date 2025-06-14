require 'bundler/setup'
Bundler.require(:default)

require_relative '../models/user'
require_relative '../models/post'
require_relative '../models/comment'
require_relative 'support/fake_searchkick'
Searchkick.client = FakeSearchkick.new

ENV['TEST_ENV_NUMBER'] ||= ''

ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:test)

RSpec.configure do |config|
  config.before(:each) do
    tables = %w[comments posts users]
    tables.each { |t| ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{t} RESTART IDENTITY CASCADE") }

    redis_url = (ENV['REDIS_URL_BASE'] || 'redis://localhost:6379') + '/' + ENV['TEST_ENV_NUMBER'].to_s
    Redis.new(url: redis_url).flushdb

    client = Searchkick.client
    %w[users posts comments].each do |base|
      index = "#{base}_#{ENV['TEST_ENV_NUMBER'] || '0'}"
      client.delete(index: index) rescue nil
      client.create(index: index)
    end
  end
end
