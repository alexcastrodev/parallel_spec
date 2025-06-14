require 'active_record'
require 'redis'
require 'searchkick'

class User < ActiveRecord::Base
  has_many :posts
  searchkick index_name: -> { "users_#{ENV['TEST_ENV_NUMBER'] || '0'}" }

  after_save :index_document

  def redis
    base = ENV['REDIS_URL_BASE'] || 'redis://localhost:6379'
    Redis.new(url: "#{base}/#{ENV['TEST_ENV_NUMBER']}")
  end

  def index_name
    "users_#{ENV['TEST_ENV_NUMBER'] || '0'}"
  end

  def index_document
    Searchkick.client.index(index: index_name, id: id, body: attributes)
    redis.set("user:#{id}", name)
  end
end
