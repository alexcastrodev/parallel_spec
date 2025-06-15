# frozen_string_literal: true

class UpdatePostBodyWorker
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post

    Post.reindex
    post.update_column(:body, "#{post.body} processed")
    Rails.cache.write("post:#{post.id}", post)
  end
end
