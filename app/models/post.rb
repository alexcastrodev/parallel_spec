# frozen_string_literal: true

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  searchkick

  after_commit :index_document

  def index_document
    Searchkick.client.index(index: searchkick_index.name, id: id, body: attributes)
    Rails.cache.write("post:#{id}", self)
  end
end
