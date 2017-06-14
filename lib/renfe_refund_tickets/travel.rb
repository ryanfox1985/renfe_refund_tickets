require 'active_record'

module RenfeRefundTickets
  class Travel < ActiveRecord::Base
    scope :past_tickets_not_refunded, -> do
      where(eligible: false)
        .where('tries < 6')
        .where('departure_date < ?', Date.today)
    end

    def city_for_input(text)
      split_char = if text.include?('-')
        '-'
      else
        ' '
      end

      text.split(split_char).map(&:capitalize).join(split_char)
    rescue Exception => e
      RenfeRefundTickets.logger_exception(e)
      ''
    end

    def origin_for_input
      city_for_input(origin)
    end

    def destination_for_input
      city_for_input(destination)
    end

    def screenshot_path
      "tmp/#{ticket_number}.png"
    end
  end
end
