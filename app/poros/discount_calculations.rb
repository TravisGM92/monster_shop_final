class DiscountCalculations

  def any_discounts?(order)
    @array_of_applicable_discounts = []
    @item_ids = order.items.pluck(:item_id)
    @discount = Discount.joins(:items).where(items: {id: @item_ids})
    !@discount.empty?
  end

  def id_of_applicable_items_for_discount
    @item_ids.select{ |id| @discount.each{ |id2| id == id2}}
  end


  def max_discount(order)
    self.id_of_applicable_items_for_discount.each do |id1|
      discount = Discount.joins(:items).where(items: {id: id1})[0]["discount_amount"]
      @order = OrderItem.where(item_id: id1)[0]
      Discount.joins(:items).where(items: {id: id1}).each do |discounts|
        if @order.quantity >= discounts.minimum_amount
          @array_of_applicable_discounts << discounts
        end
      end
      discount_2 = @array_of_applicable_discounts.max_by{ |discount| discount.discount_amount}.discount_amount
      return (order.order_items.sum('price * quantity') * ((100 - discount_2.to_f)/100)).round(2)
    end
  end

  def final_discount_calculation(order)
    if self.any_discounts?(order)
      self.max_discount(order)
    else
      order.order_items.sum('price * quantity')
    end
  end

  def check_if_discount_unique(id, minimum, discount)
    if Item.find(id.to_i).discounts != []
      if Item.find(id.to_i).discounts[0].minimum_amount == minimum.to_i && Item.find(id.to_i).discounts[0].discount_amount == discount.to_i
        return false
      end
    else
      true
    end
  end

end
