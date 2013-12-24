#Primary Author: Sylvan

require 'test_helper'

class PurchaseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user1 = users(:one)
  	@receipt1 = receipts(:one)
  end

  test "reformat phone number" do
  	phone_number_actual = "1234567890"

  	#test cases
  	phone_number_hyphens = "123-456-7890"
  	phone_number_parens = "(123)4567890"
  	phone_number_dots = "123.456.7890"
  	phone_number_hyphens_and_parens = "(123)-456-7890"
  	phone_number_random = ")1.2(---345))))6(7)8-(.)9...0----"
	phone_number_other_symbols = "[1]23%%45*67&890"
	phone_number_letters = "abc12kdsl3jl4kj56k7l890ds"

	purchase1 = Purchase.new(receipt_id: @receipt1.id,
							 owner_name: @user1.name)
	
	#for each test case, ensure we set purchase's owner_phone_number correctly
	#and that the phone number is reformatted correctly
	#hyphens
	purchase1.owner_phone_number = phone_number_hyphens
	assert_equal phone_number_hyphens, purchase1.owner_phone_number, "phone number is not hyphenated before reformatting"
	purchase1.reformat_phone_number
	assert_equal phone_number_actual, purchase1.owner_phone_number, "incorrect reformat of phone number with hyphens"

	#parens
	purchase1.owner_phone_number = phone_number_parens
	assert_equal phone_number_parens, purchase1.owner_phone_number, "phone number does not have parens before reformatting"
	purchase1.reformat_phone_number
	assert_equal phone_number_actual, purchase1.owner_phone_number, "incorrect reformat of phone number with parens"

	#dots
	purchase1.owner_phone_number = phone_number_dots
	assert_equal phone_number_dots, purchase1.owner_phone_number, "phone number does not have dots before reformatting"
	purchase1.reformat_phone_number
	assert_equal phone_number_actual, purchase1.owner_phone_number, "incorrect reformat of phone number with dots"
	
	#hyphens and parens
	purchase1.owner_phone_number = phone_number_hyphens_and_parens
	assert_equal phone_number_hyphens_and_parens, purchase1.owner_phone_number, "phone number does not have hyphens and parens before reformatting"
	purchase1.reformat_phone_number
	assert_equal phone_number_actual, purchase1.owner_phone_number, "incorrect reformat of phone number with hyphens and parens"

	#random (includes start/ends with symbol, multiple symbols in a row)
	purchase1.owner_phone_number = phone_number_random
	assert_equal phone_number_random, purchase1.owner_phone_number, "phone number does not have random hyphens, parens, and dots before reformatting"
	purchase1.reformat_phone_number
	assert_equal phone_number_actual, purchase1.owner_phone_number, "incorrect reformat of phone number with random hyphens, parens, and dots"

	#other symbols not commonly used in phone numbers - not handled by reformat_phone_number
	purchase1.owner_phone_number = phone_number_other_symbols
	assert_equal phone_number_other_symbols, purchase1.owner_phone_number, "phone number does not have other symbols before reformatting"
	purchase1.reformat_phone_number
	assert_not_equal phone_number_actual, purchase1.owner_phone_number, "reformatted symbols other than hyphens, dots, parens"


	#letters in phone number - not handled by reformat_phone_number
	purchase1.owner_phone_number = phone_number_other_symbols
	assert_equal phone_number_other_symbols, purchase1.owner_phone_number, "phone number does not have letters before reformatting"
	purchase1.reformat_phone_number
	assert_not_equal phone_number_actual, purchase1.owner_phone_number, "reformatted letters"


  end

  test "validates phone number" do
	purchase1 = Purchase.new(receipt_id: @receipt1.id,
					 owner_name: @user1.name)

	#presence: Purchase must have phone number
	assert !purchase1.save, "saved Purchase without phone number"

  	#length: phone number should be 10 digits long
  	phone_number_short = "123456789"
  	phone_number_long = "12345678910"
  	phone_number_correct_len = "1234567890"

  	#phone number too short
  	purchase1.owner_phone_number = phone_number_short
  	assert !purchase1.save, "saved Purchase with owner_phone_number length < 10 digits"

  	#phone number too long
  	purchase1.owner_phone_number = phone_number_long
  	assert !purchase1.save, "saved Purchase with owner_phone_number length > 10 digits"

  	#phone number correct length
  	purchase1.owner_phone_number = "1234567890"
  	assert purchase1.save, "failed to save Purchase with owner_phone_number length == 10 digits"

  	#numericality: phone number should only contain digits
  	phone_number_letters = "123abc7890"
  	phone_number_symbols = "123$%^7890"

  	#phone number with letters
  	purchase1.owner_phone_number = phone_number_letters
  	assert !purchase1.save, "saved Purchase with letters in owner_phone_number"

  	#phone number with symbols
  	purchase1.owner_phone_number = phone_number_symbols
  	assert !purchase1.save, "saved Purchase with symbols in owner_phone_number"

  	#uniqueness: purchase phone numbers on a receipt must be unique
  	purchase1.owner_phone_number = "1234567890"
  	purchase1.save
  	purchase2 = Purchase.new(receipt_id: @receipt1.id,
  							 owner_name: "any owner")
  	purchase2.owner_phone_number = purchase1.owner_phone_number
  	assert !purchase2.save, "saved Purchase with same phone number as another Purchase on Receipt"

  end

  test "validates owner name presence" do
  	purchase1 = Purchase.new(receipt_id: @receipt1.id,
  					 		 owner_phone_number: "1234567890")
  	assert !purchase1.save, "saved Purchase without an owner name"

  end

  test "create item" do
  	purchase1 = Purchase.create(receipt_id: @receipt1.id,
  							    owner_name: @user1.name,
  							    owner_phone_number: "1234567890")

  	purchase1.create_item("item1", 1.00)
  	assert_not_nil purchase1.items.find_by(title: "item1"), "failed to create item"

  end

  test "get total" do
  	purchase1 = Purchase.create(receipt_id: @receipt1.id,
  							    owner_name: @user1.name,
  							    owner_phone_number: "1234567890")

  	purchase1.create_item("item1", 1.00)
  	purchase1.create_item("item2", 298.02)
  	purchase1.create_item("item3", 3.33)
  	item_total = 1.00 + 298.02 + 3.33

  	assert_equal item_total, purchase1.get_total, "get total test 1: failed to sum item total correctly"

  end

end
