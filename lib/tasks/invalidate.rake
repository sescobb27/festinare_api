namespace :invalidate do
  desc "Search client's discounts and invalidate the expired ones"
  task discounts: :environment do
    Discount.invalidate!
  end

  desc "Search client's plans and invalidate the expired ones"
  task plans: :environment do
    ClientsPlan.invalidate!
  end
end
