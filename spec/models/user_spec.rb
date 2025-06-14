require 'rails_helper'

describe User do
  10.times do |i|
    it "creates user #{i}" do
      user = create(:user, name: "User #{i}")
      expect(User.find_by(name: "User #{i}")).to eq(user)

      expect(Rails.cache.read("user:#{user.id}").name).to eq("User #{i}")

      client = Searchkick.client
      result = client.get(index: user.index_name, id: user.id)
      expect(result['_source']['name']).to eq("User #{i}")
    end
  end
end
