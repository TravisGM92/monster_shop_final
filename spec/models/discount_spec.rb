require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe "relationships" do
    it { should have_many :discount_items}
    it { should have_many(:items).through(:discount_items)}
  end

  describe "instance methods" do
    it ".apply_discount" do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )

      @order_2 = @m_user.orders.create!(status: "pending")

      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 5, fulfilled: false)
      @discount_item_1 = @ogre.discounts.create!(minimum_amount: 5, discount_amount: 10)
      expect(@order_2.grand_total).to eq(91.13)
    end

    it "only the largest discount will be used" do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )

      @order_2 = @m_user.orders.create!(status: "pending")

      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 10, fulfilled: false)
      @discount_item_1 = @ogre.discounts.create!(minimum_amount: 5, discount_amount: 10)
      @discount_item_2 = @ogre.discounts.create!(minimum_amount: 10, discount_amount: 15)

      expect(@order_2.grand_total).to eq(172.13)
    end
  end
end
