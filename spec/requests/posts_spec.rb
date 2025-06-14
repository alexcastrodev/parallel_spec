require 'rails_helper'

RSpec.describe 'Posts API', type: :request do
  let(:user) { create(:user) }

  describe 'POST /users/:user_id/posts' do
    it 'creates post and caches it' do
      post "/users/#{user.id}/posts", params: {title: 'Title', body: 'Body', user_id: user.id}
      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      id = data['id']
      expect(Rails.cache.read("post:#{id}").title).to eq('Title')
      results = Post.search('Title')
      expect(results.first.id).to eq(id)
    end

    it 'returns 422 for invalid params' do
      post "/users/#{user.id}/posts", params: {body: 'Missing title', user_id: user.id}
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /users/:user_id/posts/:id' do
    it 'updates post and caches result' do
      post_record = create(:post, user: user)
      put "/users/#{user.id}/posts/#{post_record.id}", params: {title: 'New'}
      expect(response).to have_http_status(:ok)
      expect(Rails.cache.read("post:#{post_record.id}").title).to eq('New')
    end
  end
end
