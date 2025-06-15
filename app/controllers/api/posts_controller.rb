# frozen_string_literal: true

class Api::PostsController < Api::ApiController
  before_action :set_user
  before_action :set_post, only: %i[show update]

  def index
    query = params[:query].to_s
    posts = if query.empty?
              @user.posts
            else
              Post.search(query, where: { user_id: @user.id })
            end
    render json: posts.map { |p| PostSerializer.new(p).serializable_hash }
  end

  def create
    result = PostContract.new.call(params.to_unsafe_h.merge(user_id: @user.id))
    if result.success?
      post = @user.posts.create(result.to_h.except(:user_id))
      if post.persisted?
        Rails.cache.write("post:#{post.id}", post)
        render json: PostSerializer.new(post).serializable_hash, status: :created
      else
        render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: result.errors.to_h }, status: :unprocessable_entity
    end
  end

  def show
    post = Rails.cache.fetch("post:#{@post.id}") { @post }
    render json: PostSerializer.new(post).serializable_hash
  end

  def update
    attrs = @post.attributes.slice('title', 'body', 'user_id').symbolize_keys
    attrs.merge!(params.to_unsafe_h.merge(user_id: @user.id))
    result = PostContract.new.call(attrs)
    if result.success?
      if @post.update(result.to_h.except(:user_id))
        Rails.cache.write("post:#{@post.id}", @post)
        render json: PostSerializer.new(@post).serializable_hash
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
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
    @post = @user.posts.find(params[:id])
  end
end
