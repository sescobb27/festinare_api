class ClientPlan < Plan
  # =============================relationships=================================
    embedded_in :client
  # =============================END relationships=============================
  # =============================Schema========================================
    field :expired_date, type: DateTime
    field :num_of_discounts_left, type: Integer
  # =============================END Schema====================================
  default_scope -> { where(status: true) }
end
