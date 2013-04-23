# encoding: utf-8
require 'rubygems'

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'shoulda/matchers'
require 'shoulda/context'

require 'database_cleaner'
require 'capybara/rspec'
require "email_spec"
require 'spork'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  DatabaseCleaner.strategy = :truncation

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
  DatabaseCleaner.clean
  Timecop.return
  # FakeWeb.clean_registry
end

RSpec.configure do |config|

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Factory helpers
  config.include FactoryGirl::Syntax::Methods

  # Email helpers
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)

end
