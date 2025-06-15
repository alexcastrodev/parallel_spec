# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/users' do
    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }

      response '201', 'user created' do
        let(:user) { { name: 'John' } }
        run_test! do
          data = JSON.parse(response.body)
          id = data['id']
          expect(Rails.cache.read("user:#{id}").name).to eq('John')
          allow(User).to receive(:search).with('John').and_return([User.find(id)])
          results = User.search('John')
          expect(results.first.id).to eq(id)
        end
      end

      response '422', 'invalid request' do
        let(:user) { { foo: 'bar' } }
        run_test!
      end
    end
  end

  path '/api/users/{id}' do
    get 'Retrieves a user' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'user found' do
        let(:id) { create(:user, name: 'Cached').id }
        run_test! do
          Rails.cache.write("user:#{id}", User.find(id))
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Cached')
        end
      end
    end

    put 'Updates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }

      response '200', 'user updated' do
        let(:id) { create(:user).id }
        let(:user) { { name: 'Updated' } }
        run_test! do
          expect(Rails.cache.read("user:#{id}").name).to eq('Updated')
        end
      end
    end
  end

  path '/api/users' do
    get 'Searches users' do
      tags 'Users'
      produces 'application/json'
      parameter name: :query, in: :query, type: :string

      response '200', 'users found' do
        let(:query) { 'Search' }
        run_test! do
          user = create(:user, name: 'Search')
          allow(User).to receive(:search).with('Search').and_return([user])
        end
      end
    end
  end
end
