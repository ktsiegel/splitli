class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
    	t.integer :purchase_id
    	t.string :title
    	t.float :amount
        t.timestamps
    end
  end
end
