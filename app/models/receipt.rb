# Primary Author: all

class Receipt < ActiveRecord::Base
    belongs_to :user
    has_many :purchases
    #validates :total_amount, numericality: true
    #validates :tip, numericality: true
    validates :title, presence: true #every receipt must have a title
    validates_format_of :title, with: /.+/ #title is at least one character long

    #Creates an item for each person (purchase) on an evenly split bill
    #note: splits total amount, not tip
    def split_evenly
        num_people = self.purchases.length + 1
        charge_for_each = (self.total_amount.to_f / num_people.to_f)
        self.purchases.each do |purchase|
            purchase.create_item('even split contribution', charge_for_each)
        end
    end

    #splits purchases, creates charges, 
    def conduct_payment_process(tax, token)
        self.split_purchases(tax)
        total_charged = self.charge_all_purchases(token)
    end

    #cost aggregation depending on split_type using split_evenly, add_tax_and_tip, and add_only_tip
    def split_purchases(tax)
        if self.split_type == 'Split Evenly' then self.split_evenly end
        if (self.split_type == 'Itemize' and tax) or (self.split_type == 'Split Evenly' and !tax)
            self.add_tax_and_tip
        else
            self.add_only_tip
        end
    end

    #for each purchase, update the item amount to include tax
    #used if we are itemizing and there is not tax, or if we are splitting evenly and there is tax
    def add_only_tip
        self.purchases.each do |purchase|
            purchase.items.each do |item|
                item.update(amount: (item.amount*(1+self.tip.to_f*0.01)).round(2))
            end
        end
    end

    #for each purchase, update the item amount to include tax and tip
    #used if we are itemizing and there is tax, or if we are splitting evenly and there is no tax
    def add_tax_and_tip
        self.purchases.each do |purchase|
            purchase.items.each do |item|
                amnt = item.amount*(1.08)
                item.update(amount: (amnt + amnt/1.08*(self.tip.to_f*0.01)).round(2))
            end
        end
    end

    #sums item amounts for each purchase and calls charge_helper to send Venmo Charge
    def charge_all_purchases(token)
        #collect all the necessary inputs for charge_helper
        collection_of_charges = self.charge_accumulator(token)
        collection_of_charges.each do |charge|
            #for each necessary charge, create the charge through Venmo's API
            self.charge_helper(charge[0],charge[1], charge[2], charge[3])
        end
        self.total_sum
    end

    #creates all the inputs needed for charge_helper.  This is so the functionality of creating inputs, and actually sending
    #charges to venmo is separated.
    def charge_accumulator(token)
        total_sum = 0
        collection_of_charges = Array.new
        self.purchases.each do |purchase|
            sum = 0
            purchase.items.each do |item|
                sum += item.amount
            end
            #the input for charge_helper for each purchase
            helper_input = purchase.owner_phone_number.to_s, 'Splitting receipt '+self.title+' using Split.li', '-'+sum.to_s, token
            collection_of_charges << helper_input
            total_sum += sum
        end
        collection_of_charges
    end

    #returns the total sum of all item amounts.
    def total_sum
        total = 0
        self.purchases.each do |purchase|
            sum = 0
            purchase.items.each do |item|
                sum += item.amount
            end
            total += sum
        end
        total
    end

    #sends Venmo Charge
    def charge_helper(phone, note, amount, token)
        json = JSON.parse(RestClient.post('https://api.venmo.com/payments', access_token: token, phone: phone, note: note, amount: amount))
        rescue RestClient::BadRequest, RestClient::Forbidden, RestClient::Unauthorized #This should never happen, but is a safety just in case something really bad happens.
    end
end
