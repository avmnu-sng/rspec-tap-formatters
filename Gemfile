# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'rake', '~> 13.0'
end

gem 'yard', '~> 0.9', group: :documentation

group :code_analysis do
  gem 'rubocop', '~> 0.75.0'
  gem 'rubocop-performance', '~> 1.5.0'
  gem 'rubocop-rspec', '~> 1.36.0'
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'simplecov', '~> 0.17.1', require: false
end

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
