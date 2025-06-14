# frozen_string_literal: true

class CommentSerializer
  include Alba::Resource
  attributes :id, :body, :post_id
end
