FactoryGirl.define do
  factory :user do
    username              { Faker::Internet.user_name }
    password              'secret'
    password_confirmation 'secret'
  end
end
