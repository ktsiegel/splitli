class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
    	t.string :owner_phone_number
    	t.string :owner_name
    	t.integer :receipt_id
      t.timestamps
    end
  end
end
