class CreateDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :discounts do |t|
      t.integer :minimum_amount
      t.integer :discount_amount
    end
  end
end
