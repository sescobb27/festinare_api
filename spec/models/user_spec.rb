require 'rails_helper'

RSpec.describe User, :type => :model do

  describe 'User with categories' do
    it 'should have some categories' do
      (1..10).each do
        user = FactoryGirl.attributes_for :user
        user[:categories] = []
        user[:categories].concat( (1..2).map { FactoryGirl.build(:category) })
        expect{ User.create!(user) }.to_not raise_error
        u = User.find_by(username: user[:username])
        u.categories.each do |category|
          expect(user[:categories]).to include category
        end
      end
    end
  end
end
