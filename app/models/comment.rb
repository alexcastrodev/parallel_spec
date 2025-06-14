# frozen_string_literal: true

class Comment < ActiveRecord::Base
  belongs_to :post
  searchkick index_name: -> { "comments_#{ENV['TEST_ENV_NUMBER'] || '0'}" }

  after_commit :index_document

  def index_name
    "comments_#{ENV['TEST_ENV_NUMBER'] || '0'}"
  end

  def index_document
    Searchkick.client.index(index: index_name, id: id, body: attributes)
    Rails.cache.write("comment:#{id}", self)
  end
end
