FactoryGirl.define do
  factory :term do
    user
    name Faker::Lorem.word
  end
end
