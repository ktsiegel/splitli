class Session < ActiveRecord::Base
        #returns when a session should expire, based on the time the session was created.
        def expires_at
                return self.created_at + 1800
        end

        #checks if a session is active by comparing the current time to the created_at time.
        #If the current time is past the expires_at time, then the entry will be deleted from the table.
        def active_check
                if Time.now > self.expires_at
                        self.destroy
                        return false
                else
                        return true
                end
        end
end
