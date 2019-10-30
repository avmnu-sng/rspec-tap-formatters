SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/bundle/'

  minimum_coverage 100
  refuse_coverage_drop
end

SimpleCov.at_exit do
  SimpleCov.result.format!
end
