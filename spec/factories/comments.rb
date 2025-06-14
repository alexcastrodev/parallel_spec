FactoryBot.define do
  factory :comment do
    association :post
    sequence(:body) { |n| "Comment #{n}" }
  end
end
