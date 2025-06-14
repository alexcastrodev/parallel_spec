# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :posts
  searchkick

  after_commit :index_document

  def index_document
    Searchkick.client.index(index: searchkick_index.name, id: id, body: attributes)
    Rails.cache.write("user:#{id}", self)
  end
end
