require 'rails_helper'

describe Post do
  before do
    @user = create(:user, name: 'Author')
  end

  10.times do |i|
    it "creates post #{i}" do
      post = create(:post, user: @user, title: "Post #{i}")
      expect(Post.find_by(title: "Post #{i}")).to eq(post)

      expect(Rails.cache.read("post:#{post.id}").title).to eq("Post #{i}")

      client = Searchkick.client
      result = client.get(index: post.index_name, id: post.id)
      expect(result['_source']['title']).to eq("Post #{i}")
    end
  end
end
