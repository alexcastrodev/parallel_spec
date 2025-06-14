class PostsController < ApplicationController
  before_action :set_user
  before_action :set_post, only: [:show, :update]

  def create
    result = PostContract.new.call(post_params)
    if result.success?
      post = @user.posts.create(result.to_h.except(:user_id))
      if post.persisted?
        Rails.cache.write("post:#{post.id}", post)
        render json: PostSerializer.new(post).serializable_hash, status: :created
      else
        render json: {errors: post.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {errors: result.errors.to_h}, status: :unprocessable_entity
    end
  end

  def show
    post = Rails.cache.fetch("post:#{@post.id}") { @post }
    render json: PostSerializer.new(post).serializable_hash
  end

  def update
    result = PostContract.new.call(post_params)
    if result.success?
      if @post.update(result.to_h.except(:user_id))
        Rails.cache.write("post:#{@post.id}", @post)
        render json: PostSerializer.new(@post).serializable_hash
      else
        render json: {errors: @post.errors.full_messages}, status: :unprocessable_entity
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
    @post = @user.posts.find(params[:id])
  end

  def post_params
    params.permit(:title, :body, :user_id)
  end
end
