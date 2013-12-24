# Primary Author: Katie Siegel

class User < ActiveRecord::Base
        has_many :receipts

        # used to implement Venmo omniauth; creates a user 
        def self.create_with_omniauth(auth)
                create! do |user|
                        user.provider = auth["provider"]
                        user.uid = auth["uid"]
                        user.name = auth["info"]["name"]
                end
        end
end
