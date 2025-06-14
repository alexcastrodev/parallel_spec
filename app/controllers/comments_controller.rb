# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_user
  before_action :set_post
  before_action :set_comment, only: %i[show update]

  def index
    query = params[:query].to_s
    comments = if query.empty?
                 @post.comments
               else
                 Comment.search(query, where: { post_id: @post.id })
               end
    render json: comments.map { |c| CommentSerializer.new(c).serializable_hash }
  end

  def create
    result = CommentContract.new.call(params.to_unsafe_h.merge(post_id: @post.id))
    if result.success?
      comment = @post.comments.create(result.to_h.except(:post_id))
      if comment.persisted?
        Rails.cache.write("comment:#{comment.id}", comment)
        render json: CommentSerializer.new(comment).serializable_hash, status: :created
      else
        render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: result.errors.to_h }, status: :unprocessable_entity
    end
  end

  def show
    comment = Rails.cache.fetch("comment:#{@comment.id}") { @comment }
    render json: CommentSerializer.new(comment).serializable_hash
  end

  def update
    result = CommentContract.new.call(params.to_unsafe_h.merge(post_id: @post.id))
    if result.success?
      if @comment.update(result.to_h.except(:post_id))
        Rails.cache.write("comment:#{@comment.id}", @comment)
        render json: CommentSerializer.new(@comment).serializable_hash
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: result.errors.to_h }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_post
    @post = @user.posts.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end
end
