class Cart

  attr_reader :contents

  def initialize(contents)
    @contents = contents || {}
    @contents.default = 0
  end

  def add_item(item_id)
    @contents[item_id] += 1
  end

  def less_item(item_id)
    @contents[item_id] -= 1
  end

  def count
    @contents.values.sum
  end

  def items
    @contents.map do |item_id, _|
      Item.find(item_id)
    end
  end

  def grand_total
    grand_total = 0.0
    @contents.each do |item_id, quantity|
      grand_total += Item.find(item_id).price * quantity
    end
    grand_total
  end

  def count_of(item_id)
    @contents[item_id.to_s]
  end

  def discounted(item_id)
    discounts = Discount.joins(:items).where(items: {id: item_id})
    largest_discounts = discounts.max_by{ |discount| discount.discount_amount}
    if largest_discounts != nil && @contents[item_id.to_s] >= largest_discounts.minimum_amount
      discounts
    else
      []
    end
  end

  def subtotal_of(item_id)
    discounts = Discount.joins(:items).where(items: {id: item_id})
    if discounts != []
      largest_discount = discounts.order(:discount_amount).first
      (@contents[item_id.to_s] * (Item.find(item_id).price)*((100 - largest_discount.discount_amount.to_f)/100)).round(2)
    else
      @contents[item_id.to_s] * Item.find(item_id).price
    end
  end

  def limit_reached?(item_id)
    count_of(item_id) == Item.find(item_id).inventory
  end
end
