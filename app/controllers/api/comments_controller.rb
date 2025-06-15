# frozen_string_literal: true

module Api
  class CommentsController < Api::ApiController
    before_action :load_post
    before_action :load_comment, only: %i[show update]

    def index
      query = params[:query].to_s
      if query.empty?
        @post.comments
      else
        Comment.search(query, where: { post_id: @post.id })
      end
      render json: CommentSerializer.new(c).serialize
    end

    def create
      result = CommentContract.new.call(params.to_unsafe_h.merge(post_id: @post.id))
      if result.success?
        comment = @post.comments.create(result.to_h.except(:post_id))
        if comment.persisted?
          # Rails.cache.write("comment:#{comment.id}", comment)
          render json: CommentSerializer.new(comment).serialize, status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { errors: result.errors.to_h }, status: :unprocessable_entity
      end
    end

    def show
      comment = Rails.cache.fetch("comment:#{@comment.id}") { @comment }
      render json: CommentSerializer.new(comment).serialize
    end

    def update
      result = CommentContract.new.call(params.to_unsafe_h.merge(post_id: @post.id))
      if result.success?
        if @comment.update(result.to_h.except(:post_id))
          Rails.cache.write("comment:#{@comment.id}", @comment)
          render json: CommentSerializer.new(@comment).serialize
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { errors: result.errors.to_h }, status: :unprocessable_entity
      end
    end

    private

    def load_post
      @user = User.find(params[:user_id])
      @post = @user.posts.find(params[:post_id])
    end

    def load_comment
      @comment = @post.comments.find(params[:id])
    end
  end
end
