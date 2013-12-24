class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
    	t.integer :user_id
    	t.string :title
    	t.float :percent_paid
    	t.float :total_amount
    	t.float :tip
      t.string :split_type
      t.boolean :been_sent
      t.timestamps
    end
  end
end
