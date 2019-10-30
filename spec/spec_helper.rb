# frozen_string_literal: true

require 'pry'
require 'simplecov'
require 'rspec/tap/formatters'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |file|
  require file
end

RSpec.configure do |config|
  rspec_version = Gem::Version.new(RSpec::Core::Version::STRING)

  if rspec_version >= Gem::Version.new('3.3.0')
    config.example_status_persistence_file_path = 'spec/examples.txt'
  end

  config.disable_monkey_patching!

  config.expect_with(:rspec) do |expectations|
    if rspec_version >= Gem::Version.new('3.1.0')
      expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    end

    expectations.syntax = :expect
  end

  config.mock_with(:rspec) do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end
