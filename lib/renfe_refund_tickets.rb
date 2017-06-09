require 'renfe_refund_tickets/version'
require 'renfe_refund_tickets/travel'
require 'renfe_refund_tickets/ticket_creator'
require 'renfe_refund_tickets/ticket_refunder'
require 'renfe_refund_tickets/ticket_notifier'
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

    def browser
      @browser ||= RenfeRefundTickets.initialize_capybara
    end

    def logger_exception(e)
      RenfeRefundTickets.logger.error("[TicketCreator] " + e.message + e.backtrace[0..5].join("\n"))
    end

    def use_phantom()
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 60)
      end

      Capybara.javascript_driver = :poltergeist
      Capybara::Session.new(:poltergeist)
    end

    def use_selenium()
      Capybara.register_driver :selenium do |app|
        Capybara::Selenium::Driver.new(app, browser: :chrome)
      end

      Capybara.javascript_driver = :chrome

      Capybara.configure do |config|
        config.default_max_wait_time = 10 # seconds
        config.default_driver        = :selenium
      end

      Capybara::Session.new(:selenium)
    end

    def initialize_capybara(driver = ENV['RENFE_DRIVER'])
      return use_phantom if !driver || driver.to_s == 'phantom'
      use_selenium
    end

    def login_to_renfe(browser, user = ENV['RENFE_USER'], password = ENV['RENFE_PASSWORD'])
      visit(browser, 'https://venta.renfe.com/vol/login.do?Idioma=es&Pais=ES&inirenfe=SI')
      browser.fill_in 'txtoUsuario', with: user
      browser.fill_in 'password', with: password
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

    def visit(browser, link)
      tries ||= 3
      RenfeRefundTickets.logger.info("[TicketRenfe] Tries:#{tries} Visiting: #{link}")
      browser.visit(link)
      sleep(0.5)
    rescue Exception => e
      if (tries -= 1).zero?
        raise e
      else
        RenfeRefundTickets.logger_exception(e)
        retry
      end
    end
  end
end
