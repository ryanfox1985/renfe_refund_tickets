require 'renfe_refund_tickets'

module RenfeRefundTickets
  module Concerns
    module HasBrowser
      attr_accessor :browser

      def initialize
        @browser = RenfeRefundTickets.initialize_capybara
      end
    end
  end
end
