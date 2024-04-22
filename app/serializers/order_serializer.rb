class OrderSerializer < ActiveModel::Serializer
  attributes :id, :product_name, :quantity, :delivery_address
  has_one :user
end
