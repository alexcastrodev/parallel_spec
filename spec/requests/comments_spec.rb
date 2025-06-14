require 'rails_helper'

RSpec.describe 'Comments API', type: :request do
  let(:user) { create(:user) }
  let(:post_record) { create(:post, user: user) }

  describe 'POST /users/:user_id/posts/:post_id/comments' do
    it 'creates comment and caches it' do
      post "/users/#{user.id}/posts/#{post_record.id}/comments", params: {body: 'Hi', post_id: post_record.id}
      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      id = data['id']
      expect(Rails.cache.read("comment:#{id}").body).to eq('Hi')
      results = Comment.search('Hi')
      expect(results.first.id).to eq(id)
    end

    it 'returns 422 for invalid params' do
      post "/users/#{user.id}/posts/#{post_record.id}/comments", params: {foo: 'bar'}
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /users/:user_id/posts/:post_id/comments/:id' do
    it 'updates comment and caches result' do
      comment = create(:comment, post: post_record)
      put "/users/#{user.id}/posts/#{post_record.id}/comments/#{comment.id}", params: {body: 'Update'}
      expect(response).to have_http_status(:ok)
      expect(Rails.cache.read("comment:#{comment.id}").body).to eq('Update')
    end
  end
end
