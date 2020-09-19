class Order < ApplicationRecord
  has_many :order_items
  has_many :items, through: :order_items
  belongs_to :user

  enum status: ['pending', 'packaged', 'shipped', 'cancelled']

  def grand_total
    item_ids = self.items.pluck(:item_id)
    discount = Discount.joins(:items).where(items: {id: item_ids})
    if !discount.empty?
      applicable_items_for_discount = item_ids.select{ |id| discount.each{ |id2| id == id2}}
      applicable_items_for_discount.each do |id1|
        discount = Discount.joins(:items).where(items: {id: id1})[0]["discount_amount"]
        order = OrderItem.where(item_id: id1)[0]
        if order["quantity"] <= Discount.joins(:items).where(items: {id: id1})[0]["minimum_amount"]
          return (order_items.sum('price * quantity') * ((100 - discount.to_f)/100)).round(2)
        end
      end
    else
      order_items.sum('price * quantity')
    end
  end

  def count_of_items
    order_items.sum(:quantity)
  end

  def cancel
    update(status: 'cancelled')
    order_items.each do |order_item|
      order_item.update(fulfilled: false)
      order_item.item.update(inventory: order_item.item.inventory + order_item.quantity)
    end
  end

  def merchant_subtotal(merchant_id)
    order_items
      .joins("JOIN items ON order_items.item_id = items.id")
      .where("items.merchant_id = #{merchant_id}")
      .sum('order_items.price * order_items.quantity')
  end

  def merchant_quantity(merchant_id)
    order_items
      .joins("JOIN items ON order_items.item_id = items.id")
      .where("items.merchant_id = #{merchant_id}")
      .sum('order_items.quantity')
  end

  def is_packaged?
    update(status: 1) if order_items.distinct.pluck(:fulfilled) == [true]
  end

  def self.by_status
    order(:status)
  end
end
