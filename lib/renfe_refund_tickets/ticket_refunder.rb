require 'renfe_refund_tickets'
require 'renfe_refund_tickets/concerns/has_browser'

module RenfeRefundTickets
  class TicketRefunder
    include RenfeRefundTickets::Concerns::HasBrowser

    def refund_past_tickets
      RenfeRefundTickets.connect_database
      RenfeRefundTickets.login_to_renfe(@browser)

      unless @browser
        RenfeRefundTickets.logger.error("[TicketRefunder] No browser set!")
        return
      end

      Travel.past_tickets_not_refunded.each do |travel|
        refund_ok = false
        begin
          refund_ok = refund_travel_process(travel)
        rescue Exception => e
          RenfeRefundTickets.logger_exception(e)
        end

        travel.update_attributes(refund_at: DateTime.now, refund_ok: refund_ok)
      end
    end

    private

    def city_input(text)
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

    def refund_travel_process(travel)
      RenfeRefundTickets.logger.info("[TicketRefunder] refund_ticket_process")
      @browser.visit 'https://venta.renfe.com/vol/selecIndemAuto.do'

      @browser.fill_in 'cdgoBillete', with: travel.ticket_number
      @browser.fill_in 'ORIGEN', with: city_input(travel.origin)
      @browser.fill_in 'DESTINO', with: city_input(travel.destination)

      @browser.click_link('Buscar')

      begin
        return @browser.find('#error').nil?
      rescue Exception => e
        RenfeRefundTickets.logger_exception(e)
        true
      end
    end
  end
end
