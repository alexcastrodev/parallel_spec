# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :posts
  searchkick index_name: -> { "users_#{ENV['TEST_ENV_NUMBER'] || '0'}" }

  after_commit :index_document

  def index_name
    "users_#{ENV['TEST_ENV_NUMBER'] || '0'}"
  end

  def index_document
    Searchkick.client.index(index: index_name, id: id, body: attributes)
    Rails.cache.write("user:#{id}", self)
  end
end
