require 'renfe_refund_tickets/version'
require 'renfe_refund_tickets/travel'
require 'yaml'
require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'

Capybara.register_driver :poltergeist do |app|
  # We want errors to be thrown at our faces
  Capybara::Poltergeist::Driver.new(app, js_errors: true, timeout: 60)
end

Capybara.javascript_driver = :poltergeist

module RenfeRefundTickets
  # include Capybara::DSL

  def self.login(browser)
    browser.visit "https://venta.renfe.com/vol/login.do?Idioma=es&Pais=ES&inirenfe=SI"
    browser.fill_in 'txtoUsuario', with: ENV['RENFE_USER']
    browser.fill_in 'password', with: ENV['RENFE_PASSWORD']
    browser.click_link('Entrar')
  end

  def self.a_2_h(key, values)
    values.map { |element| { key => element.value } }
  end

  def self.compose_travels(pnrs, origins, destinations, departure_dates)
    data = pnrs.zip(origins).zip(destinations).zip(departure_dates).map(&:flatten)

    data.map do |datum|
      {
        pnr: datum[0],
        origin: datum[1],
        destination: datum[2],
        departure_date: datum[3]
      }
    end
  end

  def self.find_travels(browser)
    browser.visit 'https://venta.renfe.com/vol/misCompras.do'

    pnrs = browser.all('input[name="localizador"]').map(&:value)
    origins = browser.all('td[headers="Origen"]').map(&:text)
    destinations = browser.all('td[headers="Destino"]').map(&:text)
    departure_dates = browser.all('td[headers="Fecha viaje"]').map(&:text)

    compose_travels(pnrs, origins, destinations, departure_dates)
    # TODO: logger travels
  end

  def self.find_ticket_numbers(browser, travels)
    travels.map do |travel|
      browser.visit 'https://venta.renfe.com/vol/misCompras.do'

      browser.find("input[value=\"#{travel[:pnr]}\"]").click
      browser.click_link(:Consultar)

      element = browser.find('td[headers="Código de Billete"]')
      travel.merge(ticket_number: element.text)
    end
    # TODO: logger ticket_numbers
  end

  def self.connect_database(env = 'development')
    # TODO check if exist config
    database_config = YAML.load_file('db/config.yml')
    ActiveRecord::Base.establish_connection(database_config[env])
  end

  def self.save_travels(travels)
    travels.map { |travel| Travel.create(travel) }
  end

  def self.main
    connect_database
    browser = Capybara::Session.new(:poltergeist)
    login(browser)

    travels = find_travels(browser)
    travels.reject! { |travel| travel[:pnr].nil? || !Travel.find_by(pnr: travel[:pnr]).nil? }

    compleate_travels = find_ticket_numbers(browser, travels)
    objects = save_travels(compleate_travels)
  end
end
