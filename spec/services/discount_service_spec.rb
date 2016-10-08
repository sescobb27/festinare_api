require 'rails_helper'

RSpec.describe DiscountService do
  describe '::invalidate_expired_discounts' do
    it 'should invalidate all discounts' do
      clients = FactoryGirl.create_list :client_with_discounts, 20
      clients.each do |client|
        client.discounts.each do |discount|
          discount.update created_at: (
            discount.created_at - (discount.duration * 60).seconds - 1.second
          )
        end
      end

      # Rake::Task['invalidate:discounts'].invoke
      DiscountService.invalidate_expired_discounts!

      clients = Client.includes(:discounts).find(clients.map(&:id))
      clients.each do |client|
        client.discounts.each do |discount|
          expect(discount.status).to eql false
        end
      end
    end
  end

  describe '::available_categories' do
    it 'should return all available categories' do
      FactoryGirl.create_list :client_with_discounts, 10
      categories = DiscountService.available_categories
      # expect(categories).to eql User::CATEGORIES
      expect(categories - User::CATEGORIES).to eql []
    end

    pending 'no clients with active discounts'
  end

  describe '::available_discounts(categories, opts)' do
    before(:example, create_list: :clients) do
      @l_clients_with_discounts = FactoryGirl.create_list :client_with_discounts, 20
    end

    it 'should not have available discounts' do
      expect(DiscountService.available_discounts(User::CATEGORIES)).to eql []
    end

    it 'should return all discounts if no categories specifyed', create_list: :clients do
      available_discounts = DiscountService.available_discounts
      expect(available_discounts.length).to eql 100
      expect(available_discounts).to match_array @l_clients_with_discounts.flat_map(&:discounts)
    end

    it 'should not have available discounts if all of them are expired', create_list: :clients do
      @l_clients_with_discounts.each do |client|
        client.discounts.map do |discount|
          discount.update created_at: (discount.created_at - (discount.duration * 60).seconds - 1.second)
        end
      end
      expect(DiscountService.available_discounts.length).to eql 0
    end

    it 'all available discounts', create_list: :clients do
      User::CATEGORIES.each do |category|
        available_discounts = DiscountService.available_discounts([category])
        expect(available_discounts).not_to be_empty
        expect(available_discounts.flat_map(&:client).uniq).to match_array @l_clients_with_discounts
      end
    end

    it 'all available discounts with limit', create_list: :clients do
      User::CATEGORIES.each do |category|
        available_discounts = DiscountService.available_discounts([category], limit: 10)
        expect(available_discounts).not_to be_empty
        expect(available_discounts.length).to eql 10
        client_ids = available_discounts.flat_map do |discount|
          discount.client.id
        end.uniq
        # available_discounts would match the first 2 clients given that we request
        # 10 discounts and all test :client_with_discounts generate 5 discounts, so
        # you do the math
        expect(@l_clients_with_discounts.map(&:id)).to include(*client_ids)
      end
    end
  end

end
