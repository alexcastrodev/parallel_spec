# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Posts API', type: :request do
  path '/api/users/{user_id}/posts' do
    post 'Creates a post' do
      tags 'Posts'
      consumes 'application/json'
      parameter name: :user_id, in: :path, type: :integer, required: true
      parameter name: :post, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          body: { type: :string },
          user_id: { type: :integer }
        },
        required: ['title', 'body', 'user_id']
      }

      response '201', 'post created' do
        let(:user) { create(:user) }
        let(:user_id) { user.id }
        let(:post) { { title: 'Title', body: 'Body', user_id: user.id } }

        run_test! do
          data = JSON.parse(response.body)
          id = data['id']
          expect(Rails.cache.read("post:#{id}").title).to eq('Title')
        end
      end

      response '422', 'invalid request' do
        let(:user) { create(:user) }
        let(:user_id) { user.id }
        let(:post) { { body: 'Missing title', user_id: user.id } }

        run_test!
      end
    end
  end
end
