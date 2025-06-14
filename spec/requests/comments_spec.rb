require 'rails_helper'

RSpec.describe 'Comments API', type: :request do
  100.times do |i|
    context "run #{i}" do
      let(:user) { create(:user) }
      let(:post_record) { create(:post, user: user) }

      it 'creates comment and caches it' do
        post "/api/users/#{user.id}/posts/#{post_record.id}/comments", params: { body: "Hi#{i}", post_id: post_record.id }
        expect(response).to have_http_status(:created)
        data = JSON.parse(response.body)
        id = data['id']
        expect(Rails.cache.read("comment:#{id}").body).to eq("Hi#{i}")
        allow(Comment).to receive(:search).with("Hi#{i}", where: { post_id: post_record.id }).and_return([Comment.find(id)])
        results = Comment.search("Hi#{i}", where: { post_id: post_record.id })
        expect(results.first.id).to eq(id)
      end

      it 'returns 422 for invalid params' do
        post "/api/users/#{user.id}/posts/#{post_record.id}/comments", params: { foo: 'bar' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'updates comment and caches result' do
        comment = create(:comment, post: post_record)
        put "/api/users/#{user.id}/posts/#{post_record.id}/comments/#{comment.id}", params: { body: "Update#{i}" }
        expect(response).to have_http_status(:ok)
        expect(Rails.cache.read("comment:#{comment.id}").body).to eq("Update#{i}")
      end

      it 'searches comments' do
        comment = create(:comment, post: post_record, body: "Search#{i}")
        allow(Comment).to receive(:search).with("Search#{i}", where: { post_id: post_record.id }).and_return([comment])
        get "/api/users/#{user.id}/posts/#{post_record.id}/comments", params: { query: "Search#{i}" }
        expect(response).to have_http_status(:ok)
      end

      it 'shows comment' do
        comment = create(:comment, post: post_record)
        Rails.cache.write("comment:#{comment.id}", comment)
        get "/api/users/#{user.id}/posts/#{post_record.id}/comments/#{comment.id}"
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
