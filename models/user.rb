require 'active_record'
require 'redis'
require 'opensearch'

class User < ActiveRecord::Base
  has_many :posts

  after_save :index_document

  def redis
    base = ENV['REDIS_URL_BASE'] || 'redis://localhost:6379'
    Redis.new(url: "#{base}/#{ENV['TEST_ENV_NUMBER']}")
  end

  def opensearch
    OpenSearch::Client.new(url: ENV['OPENSEARCH_URL'] || 'http://opensearch:9200')
  end

  def index_name
    "users_\#{ENV['TEST_ENV_NUMBER'] || '0'}"
  end

  def index_document
    opensearch.index(index: index_name, id: id, body: attributes)
    redis.set("user:#{id}", name)
  end
end
