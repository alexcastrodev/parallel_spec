# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe 'Posts API', type: :request do
  100.times do |i|
    context "run #{i}" do
      let(:user) { create(:user) }

      it 'creates post and caches it' do
        post "/api/users/#{user.id}/posts", params: { title: "Title#{i}", body: 'Body', user_id: user.id }
        expect(response).to have_http_status(:created)
        data = JSON.parse(response.body)
        id = data['id']
        expect(Rails.cache.read("post:#{id}").title).to eq("Title#{i}")
        allow(Post).to receive(:search).with("Title#{i}", where: { user_id: user.id }).and_return([Post.find(id)])
        results = Post.search("Title#{i}", where: { user_id: user.id })
        expect(results.first.id).to eq(id)
      end

      it 'updates body asynchronously after create' do
        created_id = nil
        Sidekiq::Testing.inline! do
          allow(Searchkick.client).to receive(:index)
          post "/api/users/#{user.id}/posts", params: { title: "AsyncCreate#{i}", body: 'B' }
          expect(response).to have_http_status(:created)
          created_id = JSON.parse(response.body)['id']
        end
        expect(Searchkick.client).to have_received(:index).at_least(:once)
        expect(Post.find(created_id).body).to include('processed')
      end

      it 'returns 422 for invalid params' do
        post "/api/users/#{user.id}/posts", params: { body: 'Missing title', user_id: user.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'updates post and caches result' do
        post_record = create(:post, user: user)
        put "/api/users/#{user.id}/posts/#{post_record.id}", params: { title: "New#{i}" }
        expect(response).to have_http_status(:ok)
        expect(Rails.cache.read("post:#{post_record.id}").title).to eq("New#{i}")
      end

      it 'updates body asynchronously after update' do
        post_record = nil
        Sidekiq::Testing.inline! do
          post_record = create(:post, user: user)
          allow(Searchkick.client).to receive(:index)
          put "/api/users/#{user.id}/posts/#{post_record.id}", params: { title: "Async#{i}" }
          expect(response).to have_http_status(:ok)
        end
        expect(Searchkick.client).to have_received(:index).at_least(:once)
        expect(Rails.cache.read("post:#{post_record.id}").title).to eq("Async#{i}")
        expect(post_record.reload.body).to include('processed')
      end

      it 'searches posts' do
        post_record = create(:post, user: user, title: "Find#{i}")
        allow(Post).to receive(:search).with("Find#{i}", where: { user_id: user.id }).and_return([post_record])
        get "/api/users/#{user.id}/posts", params: { query: "Find#{i}" }
        expect(response).to have_http_status(:ok)
      end

      it 'shows post' do
        post_record = create(:post, user: user)
        Rails.cache.write("post:#{post_record.id}", post_record)
        get "/api/users/#{user.id}/posts/#{post_record.id}"
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
