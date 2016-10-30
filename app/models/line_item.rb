class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :cart

  def total_price
    product.price * quantity
  end

  def minus
    if self.quantity >1 then
      self.quantity = self.quantity - 1
    else
      self.destroy
    end
  end

end
