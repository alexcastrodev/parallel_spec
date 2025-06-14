# frozen_string_literal: true

class PostContract < Dry::Validation::Contract
  params do
    required(:title).filled(:string)
    required(:body).filled(:string)
    required(:user_id).filled(:integer)
  end
end
