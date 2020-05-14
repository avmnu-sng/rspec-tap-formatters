# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'rspec/tap/formatters/version'
require 'English'

Gem::Specification.new do |spec|
  HOMEPAGE = 'https://www.github.com/avmnu-sng/rspec-tap-formatters'

  spec.name = 'rspec-tap-formatters'
  spec.version = RSpec::TAP::Formatters::Version::STRING
  spec.platform = Gem::Platform::RUBY
  spec.authors = ['Abhimanyu Singh']
  spec.email = 'abhisinghabhimanyu@gmail.com'
  spec.homepage = HOMEPAGE
  spec.summary = 'TAP Formatters for RSpec 3'
  spec.description = <<-DESCRIPTION.gsub(/^\s+\|/, '').chomp
    |Formats RSpec-3 test report in TAP format with a proper nested display of
    |example groups and includes stats for the total number of passed,
    |failed, and pending tests per example group. It supports four different
    |TAP format styles.
  DESCRIPTION

  spec.metadata = {
    'bug_tracker_uri' => "#{HOMEPAGE}/issues",
    'changelog_uri' => "#{HOMEPAGE}/blob/master/CHANGELOG.md",
    'documentation_uri' => 'https://rspec-tap-formatters.readthedocs.io/en/latest',
    'homepage_uri' => HOMEPAGE,
    'source_code_uri' => HOMEPAGE
  }

  spec.files = %x(git ls-files -- lib/*).split($INPUT_RECORD_SEPARATOR)
  spec.files += %w[CHANGELOG.md LICENSE.md README.md .yardopts .document]
  spec.test_files = []
  spec.bindir = 'exe'
  spec.executables = []
  spec.require_path = 'lib'

  spec.required_ruby_version = '>= 2.3.0'
  spec.required_rubygems_version = '>= 2.0.0'

  spec.add_runtime_dependency 'psych', '>= 2.0', '< 4.0'
  spec.add_runtime_dependency 'rspec-core', '>= 3.0', '< 4.0'
  spec.add_development_dependency 'bundler', '>= 1.15.0', '< 3.0'
end
