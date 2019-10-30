# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'rspec/formatters/version'
require 'English'

Gem::Specification.new do |spec|
  spec.name = 'rspec-formatters'
  spec.version = RSpec::Formatters::Version::STRING
  spec.author = 'Abhimanyu Singh'
  spec.email = 'abhisinghabhimanyu@gmail.com'
  spec.homepage = 'https://www.github.com/avmnu-sng/rspec-formatters'
  spec.summary = "RSpec Formatters v#{spec.version}"
  spec.description = <<-DESCRIPTION.gsub(/^\s+\|/, '').chomp
    |Formats RSpec-3 test report in TAP format with a proper nested display of
    |example groups and include stats for the total number of passed,
    |failed, and pending tests per example group. It supports four different
    |TAP format styles.
  DESCRIPTION
  spec.license = 'MIT'

  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.3.0'
  spec.required_rubygems_version = '>= 2.0.0'

  spec.files = %x(
    git ls-files -- lib/*
  ).split($INPUT_RECORD_SEPARATOR)
  spec.files += %w[CHANGELOG.md LICENSE.md README.md .document .yardopts]
  spec.test_files = %x(
    git ls-files -- spec/**/*_spec.rb
  ).split($INPUT_RECORD_SEPARATOR)
  spec.bindir = 'exe'
  spec.executables = []
  spec.require_path = 'lib'

  spec.metadata = {
    'homepage_uri' => 'https://www.github.com/avmnu-sng/rspec-formatters',
    'changelog_uri' => 'https://www.github.com/avmnu-sng/rspec-formatters/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://www.github.com/avmnu-sng/rspec-formatters',
    'documentation_uri' => 'https://rubydoc.info/gems/rspec-formatters',
    'bug_tracker_uri' => 'https://github.com/avmnu-sng/rspec-formatters/issues'
  }

  spec.add_runtime_dependency 'psych', '>= 2.0', '< 4.0'
  spec.add_runtime_dependency 'rspec-core', '>= 3.0', '< 4.0'

  spec.add_development_dependency 'appraisal', '2.2.0'
  spec.add_development_dependency 'bundler', '>= 1.15.0', '< 3.0'
end
