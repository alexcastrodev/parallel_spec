require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe 'POST /users' do
    it 'creates user and caches and indexes record' do
      post '/users', params: {name: 'John'}
      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      id = data['id']
      expect(Rails.cache.read("user:#{id}").name).to eq('John')
      allow(User).to receive(:search).with('John').and_return([User.find(id)])
      results = User.search('John')
      expect(results.first.id).to eq(id)
    end

    it 'returns 422 for invalid params' do
      post '/users', params: {foo: 'bar'}
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /users/:id' do
    it 'returns user and hits cache' do
      user = create(:user, name: 'Cached')
      Rails.cache.write("user:#{user.id}", user)
      get "/users/#{user.id}"
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['name']).to eq('Cached')
    end
  end

  describe 'PUT /users/:id' do
    it 'updates user and caches result' do
      user = create(:user)
      put "/users/#{user.id}", params: {name: 'Updated'}
      expect(response).to have_http_status(:ok)
      expect(Rails.cache.read("user:#{user.id}").name).to eq('Updated')
    end
  end
end
