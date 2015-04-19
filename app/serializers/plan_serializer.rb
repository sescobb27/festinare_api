class PlanSerializer < MongoDocumentSerializer
  attributes :name,
             :description,
             :status,
             :price,
             :num_of_discounts,
             :currency,
             :expired_rate,
             :expired_time
end
