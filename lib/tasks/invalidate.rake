namespace :invalidate do
  desc "Search client's discounts and invalidate the expired ones"
  task discounts: :environment do
    Discount.invalidate_expired_ones
  end
end
