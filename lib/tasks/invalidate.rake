namespace :invalidate do
  desc "Search client's discounts and invalidate the expired ones"
  task discounts: :environment do
    DiscountService.invalidate_expired_discounts!
  end

  desc "Search client's plans and invalidate the expired ones"
  task plans: :environment do
    ClientsPlanService.invalidate_expired_plans!
  end

  desc "Search users's tokens and invalidate the expired ones"
  task users: :tokens do
    threads = []
    [Customer, Client].each do |klass|
      threads << Thread.new(klass.invalidate_tokens!)
    end
    threads.map(&:join)
  end
end
