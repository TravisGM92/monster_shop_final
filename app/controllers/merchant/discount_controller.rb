class Merchant::DiscountController < Merchant::BaseController
  def index
    ids_of_all_items = current_user.merchant.items.pluck(:id)
    @discounts = Discount.joins(:items).where(items: {id: ids_of_all_items})
  end

  def new
    @item = Item.find(params[:id])
  end

  def create
    item = Item.find(params[:id])
    discount = item.discounts.create!(discount_params)
    if discount.save
      redirect_to "/merchant/items"
    end
  end

  def edit
    @discount = Discount.find(params[:id])
  end

  def update
    @discount = Discount.find(params[:id])
    if @discount.update(discount_params)
      redirect_to "/merchant/discounts"
    end
  end

  def delete
    discount = Discount.find(params[:id])
    discount_item = DiscountItem.where(discount_id: discount.id)
    discount_item[0].destroy
    if discount.destroy
      flash[:success] = "The discount has been deleted"
    end
    redirect_to '/merchant/discounts'
  end

  private

  def discount_params
    params.permit(:minimum_amount, :discount_amount)
  end
end
