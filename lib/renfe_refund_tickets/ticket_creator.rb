require 'renfe_refund_tickets'
require 'renfe_refund_tickets/concerns/has_browser'

module RenfeRefundTickets
  class TicketCreator
    include RenfeRefundTickets::Concerns::HasBrowser

    def pull
      RenfeRefundTickets.connect_database
      RenfeRefundTickets.login_to_renfe(@browser)

      unless @browser
        RenfeRefundTickets.logger.error("[TicketCreator] No browser set!")
        return
      end

      travels = find_travels
      complete_travels = complete_ticket_numbers(travels)
      save_travels(complete_travels)
    end

    private

    def compose_travels(pnrs, origins, destinations, departure_dates)
      data = pnrs.zip(origins).zip(destinations).zip(departure_dates).map(&:flatten)
      return [] unless data

      data.map do |datum|
        {
          pnr: datum[0],
          origin: datum[1],
          destination: datum[2],
          departure_date: datum[3]
        }
      end
    end

    def find_travels
      RenfeRefundTickets.logger.info("[TicketCreator] find_travels")
      travels = []

      begin
        @browser.visit 'https://venta.renfe.com/vol/misCompras.do'

        pnrs = @browser.all('input[name="localizador"]').map(&:value)
        origins = @browser.all('td[headers="Origen"]').map(&:text)
        destinations = @browser.all('td[headers="Destino"]').map(&:text)
        departure_dates = @browser.all('td[headers="Fecha viaje"]').map(&:text)

        raw_travels = compose_travels(pnrs, origins, destinations, departure_dates)
        travels = raw_travels.reject do |travel|
          travel[:pnr].nil? || !Travel.find_by(pnr: travel[:pnr]).nil?
        end
      rescue Exception => e
        RenfeRefundTickets.logger_exception(e)
      end

      RenfeRefundTickets.logger.info("[TicketCreator] find_travels: #{travels}")
      travels
    end

    def complete_ticket_numbers(travels)
      RenfeRefundTickets.logger.info("[TicketCreator] complete_ticket_numbers")

      raw_complete_travels = travels.map do |travel|
        begin
          @browser.visit 'https://venta.renfe.com/vol/misCompras.do'

          @browser.find("input[value=\"#{travel[:pnr]}\"]").click
          @browser.click_link(:Consultar)

          element = @browser.find('td[headers="Código de Billete"]')
          travel.merge(ticket_number: element.text)
        rescue Exception => e
          RenfeRefundTickets.logger_exception(e)
        end
      end

      travels = raw_complete_travels.reject { |travel| travel[:ticket_number].nil? }

      RenfeRefundTickets.logger.info("[TicketCreator] complete_ticket_numbers: #{travels}")
      travels
    end

    def save_travels(travels)
      RenfeRefundTickets.logger.info("[TicketCreator] save_travels")

      saved_travels = travels.map { |travel| Travel.create(travel) }

      RenfeRefundTickets.logger.info("[TicketCreator] save_travels: #{saved_travels.inspect}")
      saved_travels
    end
  end
end
