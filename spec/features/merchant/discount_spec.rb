require 'rails_helper'

RSpec.describe 'Merchant Discount Creation' do
  describe 'As an employee of a merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
      @order_1 = @m_user.orders.create!(status: "pending")
      @order_2 = @m_user.orders.create!(status: "pending")
      @order_3 = @m_user.orders.create!(status: "pending")
      @order_item_1 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: false)
      @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: true)
      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
      @order_item_4 = @order_3.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
    end

    describe "If I visit my items index page, I see a link to 'Create a New Discount for (item name)'" do
      describe "and if I click that link I'm redirected to a page where I can" do
        it "Fill a form to create a new discount with; the minimum amount, and the percentage off" do
          visit '/merchant'

          click_link("My Items")
          within "#item-#{@giant.id}" do
            expect(page).to have_link("Create a New Discount for #{@giant.name}")
          end

          within "#item-#{@giant.id}" do
            click_link("Create a New Discount for #{@giant.name}")
          end
          expect(current_path).to eq("/merchant/items/#{@giant.id}/discount")

          fill_in 'Minimum amount', with: 5
          fill_in 'Discount amount', with: 10
          click_button 'Create New Discount'
          expect(current_path).to eq("/merchant/items")
          # save_and_open_page
          within "#item-#{@giant.id}" do
            expect(page).to have_content("\nDiscount(s) for #{@giant.name}:\n")
            expect(page).to have_content("Minimum amount: 5")
            expect(page).to have_content("Discount percentage: 10%")
          end
        end
      end
    end
  end
end

#A merchant can click a link under each item to create a new discount.
#That discount is tied to the item, which is tied to the merchant.
#The discount shows up on the index page (if you do @discount_item)
