class Cart < ApplicationRecord
  has_many :lineItems, dependent: :destroy
end
