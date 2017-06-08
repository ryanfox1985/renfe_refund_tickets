require 'active_record'

module RenfeRefundTickets
  class Travel < ActiveRecord::Base
    scope :past_tickets_not_refunded, -> do
      where(eligible: false)
        .where('tries < 4')
        .where('departure_date < ?', Date.today)
    end
  end
end
