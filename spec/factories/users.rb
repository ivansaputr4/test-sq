FactoryGirl.define do
  factory :user do
    name 'Ivan'
    email 'ivan@gmail.com'
    password '123456'
    password_confirmation '123456'
  end
end
