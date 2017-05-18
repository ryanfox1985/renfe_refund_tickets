require 'active_record'

module RenfeRefundTickets
  class Travel < ActiveRecord::Base
    scope :past_tickets_not_refunded, -> do
      where('refund_at is null and departure_date < ?', Date.today)
    end
  end
end
