# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Generate doc'
task :doc do
  sh 'yardoc'
end

desc 'Verify doc coverage'
task :verify_doc do
  sh <<-SCRIPT.gsub(/^\s+\|/, '').chomp
    |yard stats --list-undoc | ruby -e "
    |  while (line = gets)
    |    warnings ||= line.start_with?('[warn]:')
    |    coverage ||= line[/([\\d\.]+)% documented/, 1]
    |  end
    |
    |  exit(1) if warnings || Float(coverage) != 100
    |"
  SCRIPT

  sh <<-SCRIPT.gsub(/^\s+\|/, '').chomp
    |yard doc --no-cache | ruby -e "
    |  while (line = gets)
    |    warnings ||= line.start_with?('[warn]:')
    |    errors ||= line.start_with?('[error]:')
    |  end
    |
    |  exit(1) if warnings || errors
    |"
  SCRIPT
end

desc 'Run Rubocop'
task :rubocop do
  sh 'bundle exec rubocop'
end

desc 'Run all examples'
RSpec::Core::RakeTask.new(:spec)

task default: %i[verify_doc rubocop spec]
