#primary author: Sylvan

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user1 = users(:one)
    @receipt1 = receipts(:one)
    @purchase1 = purchases(:one)
  end

  test "validates amount presence" do
    item1 = Item.new(purchase_id: @purchase1.id,
                     title: "test_item_1")
    assert !item1.save, "saved Item without amount"
  end

  test "validates title presence" do
    item1 = Item.new(purchase_id: @purchase1.id,
                     amount: 1.00)
    assert !item1.save, "saved Item without title"
  end

end
