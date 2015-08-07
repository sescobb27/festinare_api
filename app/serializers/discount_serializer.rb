# == Schema Information
#
# Table name: discounts
#
#  id            :integer          not null, primary key
#  discount_rate :integer          not null
#  title         :string(100)      not null
#  secret_key    :string           not null
#  status        :boolean          default(TRUE)
#  duration      :integer          not null
#  duration_term :string           default("minutes")
#  hashtags      :string           default([]), is an Array
#  client_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class DiscountSerializer < ActiveModel::Serializer
  attributes :id,
             :discount_rate,
             :title,
             :status,
             :created_at,
             :duration,
             :duration_term,
             :hashtags
end
