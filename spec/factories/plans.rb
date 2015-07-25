FactoryGirl.define do
  factory :plan do
    name 'MyString'
    description 'MyText'
    price 1
    num_of_discounts 1
    currency 'MyString'
    expired_rate 1
    expired_time 'MyString'
  end
end
