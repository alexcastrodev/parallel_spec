class CommentsController < ApplicationController
  before_action :set_user
  before_action :set_post
  before_action :set_comment, only: [:show, :update]

  def create
    result = CommentContract.new.call(comment_params.to_h)
    if result.success?
      comment = @post.comments.create(result.to_h.except(:post_id))
      if comment.persisted?
        Rails.cache.write("comment:#{comment.id}", comment)
        render json: CommentSerializer.new(comment).serializable_hash, status: :created
      else
        render json: {errors: comment.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {errors: result.errors.to_h}, status: :unprocessable_entity
    end
  end

  def show
    comment = Rails.cache.fetch("comment:#{@comment.id}") { @comment }
    render json: CommentSerializer.new(comment).serializable_hash
  end

  def update
    result = CommentContract.new.call(comment_params.to_h)
    if result.success?
      if @comment.update(result.to_h.except(:post_id))
        Rails.cache.write("comment:#{@comment.id}", @comment)
        render json: CommentSerializer.new(@comment).serializable_hash
      else
        render json: {errors: @comment.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {errors: result.errors.to_h}, status: :unprocessable_entity
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

  def comment_params
    params.permit(:body, :post_id)
  end
end
