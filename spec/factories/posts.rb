FactoryBot.define do
  factory :post do
    association :user
    sequence(:title) { |n| "Post #{n}" }
    body { 'body' }
  end
end
