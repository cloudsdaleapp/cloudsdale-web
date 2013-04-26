# encoding: utf-8
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'shoulda/matchers'
require 'shoulda/context'

require 'database_cleaner'
require 'spork'

require 'capybara/rspec'
require 'pundit/rspec'
require 'email_spec'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Spork.prefork do

  DatabaseCleaner.strategy = :truncation

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
  end

end

Spork.each_run do
  FactoryGirl.reload
  DatabaseCleaner.clean
  Timecop.return
  # FakeWeb.clean_registry
end

RSpec.configure do |config|

  config.mock_with :rspec

  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"


  config.include FactoryGirl::Syntax::Methods
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

end
