require 'spec_helper'

describe Post do
  before do
    @user = User.create!(name: 'Author')
  end

  10.times do |i|
    it "creates post #{i}" do
      post = @user.posts.create!(title: "Post #{i}", body: 'body')
      expect(Post.find_by(title: "Post #{i}")).to eq(post)

      base = ENV['REDIS_URL_BASE'] || 'redis://localhost:6379'
      redis = Redis.new(url: "#{base}/#{ENV['TEST_ENV_NUMBER']}")
      expect(redis.get("post:#{post.id}")).to eq("Post #{i}")

      client = OpenSearch::Client.new(url: ENV['OPENSEARCH_URL'] || 'http://opensearch:9200')
      result = client.get(index: post.index_name, id: post.id)
      expect(result['_source']['title']).to eq("Post #{i}")
    end
  end
end
