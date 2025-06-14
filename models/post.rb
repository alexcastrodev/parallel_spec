require 'active_record'
require 'redis'
require 'searchkick'

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  searchkick index_name: -> { "posts_#{ENV['TEST_ENV_NUMBER'] || '0'}" }

  after_save :index_document

  def redis
    base = ENV['REDIS_URL_BASE'] || 'redis://localhost:6379'
    Redis.new(url: "#{base}/#{ENV['TEST_ENV_NUMBER']}")
  end

  def index_name
    "posts_#{ENV['TEST_ENV_NUMBER'] || '0'}"
  end

  def index_document
    Searchkick.client.index(index: index_name, id: id, body: attributes)
    redis.set("post:#{id}", title)
  end
end
