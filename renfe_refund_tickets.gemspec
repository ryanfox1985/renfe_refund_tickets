# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'renfe_refund_tickets/version'

Gem::Specification.new do |spec|
  spec.name          = "renfe_refund_tickets"
  spec.version       = RenfeRefundTickets::VERSION
  spec.authors       = ["Guillermo Guerrero"]
  spec.email         = ["wolf.fox1985@gmail.com"]

  spec.summary       = %q{Gem to try to refund your tickets from renfe.}
  spec.description   = %q{Gem to try to refund your tickets from renfe.}
  spec.homepage      = "https://github.com/ryanfox1985/renfe_refund_tickets"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'poltergeist'
  spec.add_dependency 'capybara'
  spec.add_dependency "chromedriver-helper"
  spec.add_dependency "selenium-webdriver"
  spec.add_dependency 'standalone_migrations'
  spec.add_dependency 'sqlite3'
  spec.add_dependency 'activerecord'
  spec.add_dependency 'mailgun-ruby'
  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
