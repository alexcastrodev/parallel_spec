require 'spec_helper'

describe Comment do
  before do
    @post = User.create!(name: 'Author').posts.create!(title: 't', body: 'b')
  end

  10.times do |i|
    it "creates comment #{i}" do
      comment = @post.comments.create!(body: "Comment #{i}")
      expect(Comment.find_by(body: "Comment #{i}")).to eq(comment)

      base = ENV['REDIS_URL_BASE'] || 'redis://localhost:6379'
      redis = Redis.new(url: "#{base}/#{ENV['TEST_ENV_NUMBER']}")
      expect(redis.get("comment:#{comment.id}")).to eq("Comment #{i}")

      client = Searchkick.client
      result = client.get(index: comment.index_name, id: comment.id)
      expect(result['_source']['body']).to eq("Comment #{i}")
    end
  end
end
