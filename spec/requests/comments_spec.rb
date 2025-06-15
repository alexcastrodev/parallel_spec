# frozen_string_literal: true

require 'openapi_helper'

RSpec.describe 'Comments API', type: :request do
  path '/api/users/{user_id}/posts/{post_id}/comments' do
    post 'Creates a comment' do
      tags 'Comments'
      consumes 'application/json'
      parameter name: :user_id, in: :path, type: :string, description: 'User ID'
      parameter name: :post_id, in: :path, type: :string, description: 'Post ID'
      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          body: { type: :string },
          post_id: { type: :integer }
        },
        required: ['body', 'post_id']
      }

      response '201', 'comment created' do
        let(:user) { create(:user) }
        let(:post_record) { create(:post, user: user) }
        let(:user_id) { user.id }
        let(:post_id) { post_record.id }
        let(:comment) { { body: 'Hi', post_id: post_record.id } }

        run_test! do
          data = JSON.parse(response.body)
          id = data['id']

          # Ensure the comment is cached after creation
          cached_comment = Rails.cache.read("comment:#{id}")
          expect(cached_comment.body).to eq('Hi')
        end
      end

      response '422', 'invalid request' do
        let(:user) { create(:user) }
        let(:post_record) { create(:post, user: user) }
        let(:user_id) { user.id }
        let(:post_id) { post_record.id }
        let(:comment) { { foo: 'bar' } }

        run_test!
      end
    end
  end

  path '/api/users/{user_id}/posts/{post_id}/comments/{id}' do
    put 'Updates a comment' do
      tags 'Comments'
      consumes 'application/json'
      parameter name: :user_id, in: :path, type: :string, description: 'User ID'
      parameter name: :post_id, in: :path, type: :string, description: 'Post ID'
      parameter name: :id, in: :path, type: :string, description: 'Comment ID'
      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          body: { type: :string }
        },
        required: ['body']
      }

      response '200', 'comment updated' do
        let(:user) { create(:user) }
        let(:post_record) { create(:post, user: user) }
        let(:comment_record) { create(:comment, post: post_record) }
        let(:user_id) { user.id }
        let(:post_id) { post_record.id }
        let(:id) { comment_record.id }
        let(:comment) { { body: 'Update' } }

        run_test! do
          # Update the comment first
          put "/api/users/#{user_id}/posts/#{post_id}/comments/#{id}", params: { comment: comment }, as: :json

          # Ensure the updated comment is cached correctly
          cached_comment = Rails.cache.read("comment:#{id}")
          expect(cached_comment.body).to eq('Update')
        end
      end
    end
  end
end
