require 'mailgun'

module RenfeRefundTickets
  class TicketNotifier
    class << self
      def from
        ENV['RENFE_EMAIL_FROM'] || 'info@renfe.com'
      end

      def to
        ENV['RENFE_EMAIL_TO']
      end

      def enabled?
        ENV['RENFE_MAILGUN_API_KEY'] &&
          ENV['RENFE_MAILGUN_DOMAIN'] &&
          ENV['RENFE_EMAIL_TO']
      end

      def mg_client
        @mg_client ||= Mailgun::Client.new(ENV['RENFE_MAILGUN_API_KEY'])
      end
    end

    def notify(travel)
      # Define your message parameters
      message_params =  {
        from:  RenfeRefundTickets::TicketNotifier.from,
        to: RenfeRefundTickets::TicketNotifier.to,
        subject: '[RENFE_REFUND_TICKETS] New travel eligible for refund',
        html:
          """
            <html>
              <body>
                <ul>
                  <li><b>TicketNumber:</b> #{travel.ticket_number}</li>
                  <li><b>Origin:</b> #{travel.origin_for_input}</li>
                  <li><b>Destination:</b> #{travel.destination_for_input}</li>
                  <li><b>Eligible:</b> #{travel.eligible}</li>
                </ul>
              </body>
            </html>
          """
      }

      if File.exist?(travel.screenshot_path)
        message_params[:attachment] = File.open(travel.screenshot_path, 'r')
      end

      #mb_obj.add_attachment("./tron.jpg")

      # Send your message through the client
      RenfeRefundTickets::TicketNotifier.mg_client.send_message(
        ENV['RENFE_MAILGUN_DOMAIN'], message_params
      )
    end
  end
end
