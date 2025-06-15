# frozen_string_literal: true

class Comment < ActiveRecord::Base
  belongs_to :post
  searchkick

  after_commit :index_document

  def index_document
    Comment.reindex
    Rails.cache.write("comment:#{id}", self)
  end
end
