# frozen_string_literal: true

class CommentContract < Dry::Validation::Contract
  params do
    required(:body).filled(:string)
    required(:post_id).filled(:integer)
  end
end
