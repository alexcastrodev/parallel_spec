require 'rails_helper'

describe Comment do
  before do
    @post = create(:post)
  end

  10.times do |i|
    it "creates comment #{i}" do
      comment = create(:comment, post: @post, body: "Comment #{i}")
      expect(Comment.find_by(body: "Comment #{i}")).to eq(comment)

      expect(Rails.cache.read("comment:#{comment.id}").body).to eq("Comment #{i}")

      client = Searchkick.client
      result = client.get(index: comment.index_name, id: comment.id)
      expect(result['_source']['body']).to eq("Comment #{i}")
    end
  end
end
