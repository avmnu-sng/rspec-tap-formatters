# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.ruby_opts = %w[-w]
  task.verbose = false
end

desc 'Default: run the rspec examples'
task default: [:spec]
