# frozen_string_literal: true

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  searchkick index_name: -> { "posts_#{ENV['TEST_ENV_NUMBER'] || '0'}" }

  after_commit :index_document

  def index_name
    "posts_#{ENV['TEST_ENV_NUMBER'] || '0'}"
  end

  def index_document
    Searchkick.client.index(index: index_name, id: id, body: attributes)
    Rails.cache.write("post:#{id}", self)
  end
end
