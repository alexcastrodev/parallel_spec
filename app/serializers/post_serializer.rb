# frozen_string_literal: true

class PostSerializer
  include Alba::Resource
  attributes :id, :title, :body, :user_id
end
