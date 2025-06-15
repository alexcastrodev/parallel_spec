# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :posts
  searchkick

  after_commit :index_document
  before_create :set_default_name

  def set_default_name
    sleep 1 # Simulate a delay for testing purposes
  end

  def index_document
    User.reindex
    Rails.cache.write("user:#{id}", self)
  end
end
