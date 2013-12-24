#primary author: Sylvan
#prevents duplicate charges - user can't add same phone number to receipt twice
class UniquePhoneNumber < ActiveModel::Validator
	def validate(record)
		record.receipt.purchases.each do |p|
			if p.owner_phone_number == record.owner_phone_number
				record.errors[:base] << "phone number already used"
			end
		end
	end
end

class Purchase < ActiveRecord::Base
	belongs_to :receipt
	has_many :items

	before_validation :reformat_phone_number

	#must have valid phone number (10 digits), unique to that receipt
	validates :owner_phone_number, presence: true
	#validates :owner_phone_number, format: {with: /\d{10}/, message: "invalid phone number"}
	validates_length_of :owner_phone_number, :is => 10
	validates :owner_phone_number, numericality: true
	validates_with UniquePhoneNumber

	#can have 0-2 decimal places
	#validates :amount, format: {with: /\d*\.*\d{0,2}/, message: "invalid amount input"}

	validates :owner_name, presence: true

	

	#changes phone number formats with parens, hyphens, periods, spaces to valid format (numbers only)
	def reformat_phone_number
		self.owner_phone_number = self.owner_phone_number.to_s.gsub(' ', '').gsub('(', '').gsub(')', '').gsub('-', '').gsub('.', '')
	end

	#given a string name and float amount, creates a new Item associated with the Purchase
	def create_item(name, amount)
		i = Item.new(title: name, amount: amount, purchase_id: self.id)
		unless i.save
			flash[:alert] = "Error adding an item."
		end
	end

	#returns the total cost of all items
	def get_total
		total = 0
		self.items.each do |item|
			total += item.amount
		end
		total
	end
end
