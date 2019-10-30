SimpleCov.start do
  add_filter '/lib/rspec/tap/formatters/core_ext/'
  add_filter '/resources/'
  add_filter '/spec/'
  add_filter '/vendor/bundle/'

  if Gem::Version.new(RSpec::Core::Version::STRING) >= Gem::Version.new('3.3.0')
    minimum_coverage 100
    refuse_coverage_drop
  end
end

SimpleCov.at_exit do
  SimpleCov.result.format!
end
