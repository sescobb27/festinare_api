class ClientPlanSerializer < MongoDocumentSerializer
  attributes :name,
             :description,
             :status,
             :price,
             :num_of_discounts,
             :currency,
             :expired_rate,
             :expired_time,
             :expired_date,
             :num_of_discounts_left

end
