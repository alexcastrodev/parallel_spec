# frozen_string_literal: true

class UserContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
  end
end
