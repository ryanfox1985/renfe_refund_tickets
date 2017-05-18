require 'renfe_refund_tickets/version'
require 'renfe_refund_tickets/travel'
require 'renfe_refund_tickets/ticket_creator'
require 'renfe_refund_tickets/ticket_refunder'
require 'renfe_refund_tickets/concerns/has_browser'
require 'yaml'
require 'capybara'
require 'capybara/poltergeist'

module RenfeRefundTickets
  class << self
    attr_accessor :logger

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def logger_exception(e)
      RenfeRefundTickets.logger.error("[TicketCreator] " + e.message + e.backtrace[0..5].join("\n"))
    end

    def initialize_capybara
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, js_errors: true, timeout: 60)
      end

      Capybara.javascript_driver = :poltergeist
      Capybara::Session.new(:poltergeist)
    end

    def login_to_renfe(browser)
      browser.visit "https://venta.renfe.com/vol/login.do?Idioma=es&Pais=ES&inirenfe=SI"
      browser.fill_in 'txtoUsuario', with: ENV['RENFE_USER']
      browser.fill_in 'password', with: ENV['RENFE_PASSWORD']
      browser.click_link('Entrar')
    rescue Exception => e
      RenfeRefundTickets.logger_exception(e)
    end

    def connect_database(env = 'development')
      # TODO check if exist config
      database_config = YAML.load_file('db/config.yml')
      ActiveRecord::Base.establish_connection(database_config[env])
    end

    def pull_new_tickets
      TicketCreator.new.pull
    end

    def refund_tickets
      TicketRefunder.new.refund_past_tickets
    end
  end
end
