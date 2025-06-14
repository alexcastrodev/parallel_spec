require 'spec_helper'

describe User do
  10.times do |i|
    it "creates user #{i}" do
      user = User.create!(name: "User #{i}")
      expect(User.find_by(name: "User #{i}")).to eq(user)

      base = ENV['REDIS_URL_BASE'] || 'redis://localhost:6379'
      redis = Redis.new(url: "#{base}/#{ENV['TEST_ENV_NUMBER']}")
      expect(redis.get("user:#{user.id}")).to eq("User #{i}")

      client = Searchkick.client
      result = client.get(index: user.index_name, id: user.id)
      expect(result['_source']['name']).to eq("User #{i}")
    end
  end
end
