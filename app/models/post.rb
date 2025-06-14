# frozen_string_literal: true

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  searchkick

  after_commit :enqueue_update_job

  def enqueue_update_job
    UpdatePostBodyWorker.perform_async(id)
  end
end
