require 'rails_helper'

RSpec.describe 'Merchant Discount Creation' do
  describe 'As an employee of a merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 10 )
      @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
      @order_1 = @m_user.orders.create!(status: "pending")
      @order_2 = @m_user.orders.create!(status: "pending")
      @order_3 = @m_user.orders.create!(status: "pending")
    end

    describe "If I visit my items index page, I see a link to 'Create a New Discount for (item name)'" do
      describe "and if I click that link I'm redirected to a page where I can" do
        it "Fill a form to create a new discount with; the minimum amount, and the percentage off" do
          @order_item_1 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: false)
          @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: true)
          @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
          @order_item_4 = @order_3.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)

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
          within "#item-#{@giant.id}" do
            expect(page).to have_content("\nDiscount(s) for #{@giant.name}:\n")
            expect(page).to have_content("Minimum amount: 5")
            expect(page).to have_content("Discount percentage: 10%")
          end
        end
      end
    end
      it "A merchant can have multiple bulk discounts" do
        @order_item_1 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: false)
        @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: true)
        @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
        @order_item_4 = @order_3.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)

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

        visit '/merchant'

        click_link("My Items")
        within "#item-#{@ogre.id}" do
          expect(page).to have_link("Create a New Discount for #{@ogre.name}")
        end

        within "#item-#{@ogre.id}" do
          click_link("Create a New Discount for #{@ogre.name}")
        end
        expect(current_path).to eq("/merchant/items/#{@ogre.id}/discount")

        fill_in 'Minimum amount', with: 5
        fill_in 'Discount amount', with: 10
        click_button 'Create New Discount'
        expect(current_path).to eq("/merchant/items")

        within "#item-#{@giant.id}" do
          expect(page).to have_content("\nDiscount(s) for #{@giant.name}:\n")
          expect(page).to have_content("Minimum amount: 5")
          expect(page).to have_content("Discount percentage: 10%")
        end
        within "#item-#{@ogre.id}" do
          expect(page).to have_content("\nDiscount(s) for #{@ogre.name}:\n")
          expect(page).to have_content("Minimum amount: 5")
          expect(page).to have_content("Discount percentage: 10%")
        end
    end
    it "As a user, I can see the discount reflected on my check-out page" do
      discount = @ogre.discounts.create!(minimum_amount: 5, discount_amount: 10)
      @user = User.create!(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan_1@example.com', password: 'securepassword')
      @order_1 = @user.orders.create!(status: "packaged")
      @order_2 = @user.orders.create!(status: "pending")
      @order_item_1 = @order_1.order_items.create!(item: @ogre, price: @ogre.price, quantity: 5, fulfilled: true)
      @order_item_2 = @order_2.order_items.create!(item: @giant, price: @hippo.price, quantity: 2, fulfilled: true)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit "/profile/orders/#{@order_1.id}"

      expect(page).to have_content(@order_1.id)
      expect(page).to have_content("Created On: #{@order_1.created_at}")
      expect(page).to have_content("Updated On: #{@order_1.updated_at}")
      expect(page).to have_content("Status: #{@order_1.status}")
      expect(page).to have_content("#{@order_1.count_of_items} items")
      expect(page).to have_content("Total: $#{@order_1.grand_total}")

      expect(page).to have_content("Your #{@ogre.name} met the minimum discount requirement. Discount of #{discount.discount_amount}% applied!")
    end
    it "A merchant can view all discounts and delete a discount" do
      @discount_1 = @ogre.discounts.create!(minimum_amount: 5, discount_amount: 10)
      @discount_2 = @ogre.discounts.create!(minimum_amount: 10, discount_amount: 15)
      @discount_3 = @hippo.discounts.create!(minimum_amount: 3, discount_amount: 10)
      @discount_4 = @giant.discounts.create!(minimum_amount: 5, discount_amount: 10)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)

      visit("/merchant/discounts")
      expect(page).to_not have_content("You haven't created any discounts yet!")

      within "#discount-#{@discount_1.id}" do
        expect(page).to have_content("Item: #{@ogre.name}")
        expect(page).to have_content("\nDiscount: buy at least #{@discount_1.minimum_amount}")
        expect(page).to have_content("and receive #{@discount_1.discount_amount}% off")
        expect(page).to have_button("Delete discount")
      end

      within "#discount-#{@discount_2.id}" do
        expect(page).to have_content("Item: #{@ogre.name}")
        expect(page).to have_content("\nDiscount: buy at least #{@discount_2.minimum_amount}")
        expect(page).to have_content("and receive #{@discount_2.discount_amount}% off")
        expect(page).to have_button("Delete discount")
      end

      within "#discount-#{@discount_4.id}" do
        expect(page).to have_content("Item: #{@giant.name}")
        expect(page).to have_content("\nDiscount: buy at least #{@discount_4.minimum_amount}")
        expect(page).to have_content("and receive #{@discount_4.discount_amount}%")
        expect(page).to have_button("Delete discount")
        click_button("Delete discount")
      end

      expect(current_path).to eq("/merchant/discounts")
      expect(page).to_not have_content("Item: #{@giant.name}")
    end

    it "A merchant can edit/update a discount" do
      @discount_1 = @ogre.discounts.create!(minimum_amount: 5, discount_amount: 10)
      @discount_2 = @ogre.discounts.create!(minimum_amount: 10, discount_amount: 15)
      @discount_3 = @hippo.discounts.create!(minimum_amount: 3, discount_amount: 10)
      @discount_4 = @giant.discounts.create!(minimum_amount: 5, discount_amount: 10)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)

      visit("/merchant/discounts")
      expect(page).to_not have_content("You haven't created any discounts yet!")

      within "#discount-#{@discount_1.id}" do
        expect(page).to have_content("Item: #{@ogre.name}")
        expect(page).to have_content("\nDiscount: buy at least #{@discount_1.minimum_amount}")
        expect(page).to have_content("and receive #{@discount_1.discount_amount}% off")
        expect(page).to have_button("Delete discount")
        expect(page).to have_button("Edit discount")
      end

      within "#discount-#{@discount_2.id}" do
        expect(page).to have_content("Item: #{@ogre.name}")
        expect(page).to have_content("\nDiscount: buy at least #{@discount_2.minimum_amount}")
        expect(page).to have_content("and receive #{@discount_2.discount_amount}% off")
        expect(page).to have_button("Edit discount")
      end

      within "#discount-#{@discount_4.id}" do
        expect(page).to have_content("Item: #{@giant.name}")
        expect(page).to have_content("\nDiscount: buy at least #{@discount_4.minimum_amount}")
        expect(page).to have_content("and receive #{@discount_4.discount_amount}%")
        expect(page).to have_button("Edit discount")
        click_button("Edit discount")
      end

      expect(page).to have_content("Edit Discount")

      fill_in 'Minimum amount', with: 12
      fill_in 'Discount amount', with: 25
      click_on("Update discount")
      expect(current_path).to eq("/merchant/discounts")

      within "#discount-#{@discount_4.id}" do
        expect(page).to have_content("Item: #{@giant.name}")
        expect(page).to have_content("\nDiscount: buy at least 12")
        expect(page).to have_content("and receive 25% off")
        expect(page).to have_button("Edit discount")
      end

    end

    it "If there are two discounts, the larger of all discounts that apply will persist" do
      @user = User.create!(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan_1@example.com', password: 'securepassword')
      @order_1 = @user.orders.create!(status: "packaged")
      @order_2 = @user.orders.create!(status: "pending")
      @order_item_1 = @order_1.order_items.create!(item: @ogre, price: @ogre.price, quantity: 10, fulfilled: true)
      @order_item_2 = @order_2.order_items.create!(item: @giant, price: @hippo.price, quantity: 2, fulfilled: true)
      @discount_1 = @ogre.discounts.create!(minimum_amount: 5, discount_amount: 10)
      @discount_2 = @ogre.discounts.create!(minimum_amount: 10, discount_amount: 15)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit "/profile/orders/#{@order_1.id}"

      expect(page).to have_content(@order_1.id)
      expect(page).to have_content("Created On: #{@order_1.created_at}")
      expect(page).to have_content("Updated On: #{@order_1.updated_at}")
      expect(page).to have_content("Status: #{@order_1.status}")
      expect(page).to have_content("#{@order_1.count_of_items} items")
      expect(page).to have_content("Total: $#{@order_1.grand_total}")

      expect(page).to have_content("Your #{@ogre.name} met the minimum discount requirement. Discount of 15% applied!")
    end
  end
end
