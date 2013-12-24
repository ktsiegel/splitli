class Item < ActiveRecord::Base
    belongs_to :purchase
    validates :amount, presence: true
    validates :title, presence: true
    validates :amount, numericality: true
end

