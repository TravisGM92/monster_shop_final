class Merchant::DiscountController < Merchant::BaseController
  def index
    ids_of_all_items = current_user.merchant.items.map{ |item| item.id}
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

  # def edit
  #   @item = Item.find(params[:id])
  # end

  # def update
  #   @item = Item.find(params[:id])
  #   if @item.update(item_params)
  #     redirect_to "/merchant/items"
  #   else
  #     generate_flash(@item)
  #     render :edit
  #   end
  # end

  # def change_status
  #   item = Item.find(params[:id])
  #   item.update(active: !item.active)
  #   if item.active?
  #     flash[:notice] = "#{item.name} is now available for sale"
  #   else
  #     flash[:notice] = "#{item.name} is no longer for sale"
  #   end
  #   redirect_to '/merchant/items'
  # end

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
