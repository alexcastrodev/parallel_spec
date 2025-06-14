# frozen_string_literal: true

class Comment < ActiveRecord::Base
  belongs_to :post
  searchkick

  after_commit :index_document

  def index_document
    Searchkick.client.index(index: searchkick_index.name, id: id, body: attributes)
    Rails.cache.write("comment:#{id}", self)
  end
end
