# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :code_analysis do
  gem 'rubocop', '~> 0.76.0'
  gem 'rubocop-performance', '~> 1.5.0'
  gem 'rubocop-rspec', '~> 1.36.0'
end

group :documentation do
  gem 'github-markup', '~> 3.0.4'
  gem 'redcarpet', '~> 3.5.0'
  gem 'yard', '~> 0.9'
end

group :development, :test do
  gem 'pry', '~> 0.12.2'
  gem 'pry-byebug', '~> 3.7.0'
  gem 'rake', '~> 13.0'
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'simplecov', '~> 0.17.1', require: false
end

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)
