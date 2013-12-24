#primary author: Sylvan

require 'test_helper'

class ReceiptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "validates title" do
  	#presence
  	receipt1 = Receipt.new
  	assert !receipt1.save, "saved Receipt without a title"

	#format: title must be at least one character
  	receipt1.title = ""
  	assert !receipt1.save, "saved Receipt with title length < 1"

  	receipt1.title = "a"
  	assert receipt1.save, "failed to save Receipt with appropriate title"

  end

  test "split evenly" do
  	#testing even split of total amount of receipt (note: does not include tip)
  	receipt1 = Receipt.create(title: "test_receipt_1",
  							  total_amount: 12.00)

  	purchase1 = Purchase.create(receipt_id: receipt1.id,
  								owner_name: "test_owner_1",
  								owner_phone_number: "1111111111")
  	purchase2 = Purchase.create(receipt_id: receipt1.id,
  								owner_name: "test_owner_2",
  								owner_phone_number: "2222222222")

	expected_charge = receipt1.total_amount / 3
  	receipt1.split_evenly

  	#split evenly should only create one Item per Purchase
  	assert_equal purchase1.items.first, purchase1.items.last, "only one item created for owner 1"
  	assert_equal purchase2.items.first, purchase2.items.last, "only one item created for owner 2"
  	
  	#split evenly should charge amount/(#purchases + 1)
  	assert_equal expected_charge, purchase1.items.first.amount, "failed to charge owner 1 with expected amount"
  	assert_equal expected_charge, purchase2.items.first.amount, "failed to charge owner 2 with expected amount"

  end

  test "add only tip" do
  	receipt1 = Receipt.create(title: "test_receipt_1",
  							  total_amount: 12.00,
  							  tip: 10)

  	purchase1 = Purchase.create(receipt_id: receipt1.id,
  								owner_name: "test_owner_1",
  								owner_phone_number: "1111111111")

  	item1 = Item.create(purchase_id: purchase1.id,
  						title: "item1",
  						amount: 1.00)

  	item2 = Item.create(purchase_id: purchase1.id,
  	 					title: "item1",
  	 					amount: 2.22)

  	expected_new_amount1 = (1.00 * 1.1).round(2)
  	expected_new_amount2 = (2.22 * 1.1).round(2)

  	receipt1.add_only_tip

  	assert_equal expected_new_amount1, receipt1.purchases[0].items[0].amount, "failed to add tip correctly for item1"
  	assert_equal expected_new_amount2, receipt1.purchases[0].items[1].amount, "failed to add tip correctly for item2"

  end

  test "add tax and tip" do
  	receipt1 = Receipt.create(title: "test_receipt_1",
  							  total_amount: 12.00,
  							  tip: 10)

  	purchase1 = Purchase.create(receipt_id: receipt1.id,
  								owner_name: "test_owner_1",
  								owner_phone_number: "1111111111")

  	item1 = Item.create(purchase_id: purchase1.id,
  						title: "item1",
  						amount: 1.01)

  	item2 = Item.create(purchase_id: purchase1.id,
  						title: "item1",
  						amount: 2.21)

  	expected_new_amount1 = ((1.00 * 1.08) * 1.1).round(2)
  	expected_new_amount2 = ((2.20 * 1.08) * 1.1).round(2)

  	receipt1.add_tax_and_tip

  	assert_equal expected_new_amount1, receipt1.purchases[0].items[0].amount, "failed to add tax and tip correctly for item1"
  	assert_equal expected_new_amount2, receipt1.purchases[0].items[1].amount, "failed to add tax and tip correctly for item2"

  end


  test "split purchases" do
  	#test case: split evenly, no tax
  	receipt1 = Receipt.create(title: "test_receipt_1",
  							  total_amount: 12.00,
  							  split_type: "Split Evenly")

  	purchase1 = Purchase.create(receipt_id: receipt1.id,
  								owner_name: "test_owner_1",
  								owner_phone_number: "1111111111")

  	purchase2 = Purchase.create(receipt_id: receipt1.id,
  								owner_name: "test_owner_2",
  								owner_phone_number: "2222222222")

  	tax = nil

  	receipt1.split_purchases(tax)

  	expected_charge = (4.00 * 1.08).round(2)
  	assert_equal expected_charge, receipt1.purchases[0].items[0].amount, "failed to split purchases for test case split evenly without tax, purchase1"
  	assert_equal expected_charge, receipt1.purchases[1].items[0].amount, "failed to split purchases for test case split evenly without tax, purchase2"

  	#test case: split evenly, tax
  	receipt2 = Receipt.create(title: "test_receipt_1",
  							  total_amount: 12.00,
  							  split_type: "Split Evenly")

  	purchase1 = Purchase.create(receipt_id: receipt2.id,
  								owner_name: "test_owner_1",
  								owner_phone_number: "1111111111")


  	purchase2 = Purchase.create(receipt_id: receipt2.id,
  								owner_name: "test_owner_2",
  								owner_phone_number: "2222222222")


  	tax = "yes"

  	receipt2.split_purchases(tax)

	expected_charge = 4.00
  	assert_equal expected_charge, receipt2.purchases[0].items[0].amount, "failed to split purchases for test case split evenly without tax, purchase1"
  	assert_equal expected_charge, receipt2.purchases[1].items[0].amount, "failed to split purchases for test case split evenly without tax, purchase2"




  end

  #note: we do not test charge_helper or methods that call
  #charge_helper (conduct_payment_process, charge_all_purchases)
  #which are methods in our receipt model as they rely on
  #third-party (Venmo) API

end