require 'renfe_refund_tickets'
require 'renfe_refund_tickets/concerns/has_browser'

module RenfeRefundTickets
  class TicketRefunder
    include RenfeRefundTickets::Concerns::HasBrowser

    MY_TICKETS_URL = 'https://venta.renfe.com/vol/selecIndemAuto.do'

    def refund_past_tickets
      RenfeRefundTickets.connect_database
      RenfeRefundTickets.login_to_renfe(@browser)

      unless @browser
        RenfeRefundTickets.logger.error("[TicketRefunder] No browser set!")
        return
      end

      Travel.past_tickets_not_refunded.each do |travel|
        new_attributes = {
          last_try_refund_at: DateTime.now,
          tries: travel.tries + 1,
          eligible: false
        }

        begin
          new_attributes[:eligible] = refund_travel_process(travel)
        rescue Exception => e
          RenfeRefundTickets.logger_exception(e)
          next
        end

        travel.update_attributes(new_attributes)
        if travel.eligible && RenfeRefundTickets::TicketNotifier.enabled?
          TicketNotifier.new.notify(travel)
        end
      end
    end

    private

    def fill_input(id, value)
      @browser.fill_in id, with: value
      sleep(0.8)
      @browser.find("##{id}").send_keys(:return)
      sleep(0.3)
    end

    def refund_travel_process(travel)
      begin
        RenfeRefundTickets.logger.info("[TicketRefunder] refund_ticket_process: #{travel.inspect}")
        RenfeRefundTickets.visit(@browser, MY_TICKETS_URL)
        @browser.find('body').send_keys(:escape)
        sleep(0.2)

        fill_input('cdgoBillete', travel.ticket_number)
        fill_input('ORIGEN', travel.origin_for_input)
        fill_input('DESTINO', travel.destination_for_input)
        @browser.click_link('Buscar')

        @browser.save_screenshot(travel.screenshot_path, full: true)
        @browser.body.include?('forma de pago')
      rescue Exception => e
        RenfeRefundTickets.logger_exception(e)
        false
      end
    end
  end
end
