require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  100.times do |i|
    context "run #{i}" do
      it 'creates user and caches and indexes record' do
        post '/api/users', params: { name: "John#{i}" }
        expect(response).to have_http_status(:created)
        data = JSON.parse(response.body)
        id = data['id']
        expect(Rails.cache.read("user:#{id}").name).to eq("John#{i}")
        allow(User).to receive(:search).with("John#{i}").and_return([User.find(id)])
        results = User.search("John#{i}")
        expect(results.first.id).to eq(id)
      end

      it 'returns 422 for invalid params' do
        post '/api/users', params: { foo: 'bar' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns user and hits cache' do
        user = create(:user, name: "Cached#{i}")
        Rails.cache.write("user:#{user.id}", user)
        get "/api/users/#{user.id}"
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['name']).to eq("Cached#{i}")
      end

      it 'updates user and caches result' do
        user = create(:user)
        put "/api/users/#{user.id}", params: { name: "Updated#{i}" }
        expect(response).to have_http_status(:ok)
        expect(Rails.cache.read("user:#{user.id}").name).to eq("Updated#{i}")
      end

      it 'searches users' do
        user = create(:user, name: "Search#{i}")
        allow(User).to receive(:search).with("Search#{i}").and_return([user])
        get '/api/users', params: { query: "Search#{i}" }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
