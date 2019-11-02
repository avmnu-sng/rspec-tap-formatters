[![Gem Version](https://badge.fury.io/rb/rspec-tap-formatters.svg)](https://badge.fury.io/rb/rspec-tap-formatters)
[![Build Status](https://travis-ci.com/avmnu-sng/rspec-tap-formatters.svg?branch=master)](https://travis-ci.com/avmnu-sng/rspec-tap-formatters)
[![Documentation Status](https://readthedocs.org/projects/rspec-tap-formatters/badge/?version=latest)](https://rspec-tap-formatters.readthedocs.io/en/latest/?badge=latest)
[![Inline docs](http://inch-ci.org/github/avmnu-sng/rspec-tap-formatters.svg?branch=master)](http://inch-ci.org/github/avmnu-sng/rspec-tap-formatters)
[![Maintainability](https://api.codeclimate.com/v1/badges/7dd41099b7e8569fc7ec/maintainability)](https://codeclimate.com/github/avmnu-sng/rspec-tap-formatters/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/7dd41099b7e8569fc7ec/test_coverage)](https://codeclimate.com/github/avmnu-sng/rspec-tap-formatters/test_coverage)
[![Gitter](https://badges.gitter.im/rspec-tap-formatters/community.svg)](https://gitter.im/rspec-tap-formatters/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

**RSpec TAP Formatters** provides four different [TAP 13](https://testanything.org/tap-version-13-specification.html) format style with 
a proper nested display of example groups and includes stats for the total 
number of passed, failed, and pending tests per example group. The supported 
formats are:

1. `RSpec::TAP::Formatters::Default`
2. `RSpec::TAP::Formatters::Compact`
3. `RSpec::TAP::Formatters::Flat`
4. `RSpec::TAP::Formatters::FlatCompact`

Each formatter respects the color configuration for the execution and only 
prints colored output when enabled. However, writing to a file will never use 
colors.

When writing the report to a file, each formatter will print progress status 
on the standard output:
- `.` denotes a passing example.
- `F` denotes a failing example.
- `*` denotes a pending example.

Sample report for [string_spec.rb](resources/string_spec.rb) using 
`RSpec::TAP::Formatters::Default` format:
```text
TAP version 13
# test: String {
  # group: #present? {
    # group: when whitespaces and other characters {
      ok 1 - returns true
      1..1
      # tests: 1, passed: 1
    }
    # group: when nil {
      not ok 1 - returns false
        ---
        location: "./resources/string_spec.rb:8"
        error: |-
          Failure/Error: expect(string.present?).to eq(false)
          NoMethodError:
            undefined method `present?' for nil:NilClass
        backtrace: "./resources/string_spec.rb:9:in `block (4 levels) in <top (required)>'"
        ...
      1..1
      # tests: 1, failed: 1
    }
    # group: when whitespaces only {
      ok 1 - returns false
      1..1
      # tests: 1, passed: 1
    }
    1..3
    # tests: 3, passed: 2, failed: 1
  }
  1..3
  # tests: 3, passed: 2, failed: 1
}
1..3
# tests: 3, passed: 2, failed: 1
# duration: 0.026471 seconds
# seed: 27428
```

You can check the reports for other formats [here](resources/reports).

## Installation

Installation is pretty standard:
```sh
gem install rspec-tap-formatters
```

You can install using `bundler` also but do not require it in `Gemfile`.
Make sure to use it as a test dependency:
```ruby
group :test do
  # other gems
  gem 'rspec-tap-formatters', '~> 0.1.0', require: false
end
```

You can also install using the GitHub package registry:
```ruby
source 'https://rubygems.pkg.github.com/avmnu-sng' do
  gem 'rspec-tap-formatters', '~> 0.1.0', require: false
end
```

## Usage

You can specify the format as the command argument:
```sh
rspec --format RSpec::TAP::Formatters::Default
```

To write to file, provide the `--out` argument:
```sh
rspec --format RSpec::TAP::Formatters::Default --out report.tap
```

You can also configure the `.rspec` file:
```sh
# other configurations
--format RSpec::TAP::Formatters::Default
--out report.tap
```

## Documentation
Read more about TAP specifications and supported formats in the [official docs](https://rspec-tap-formatters.readthedocs.io/en/latest/).

## Source Code Documentation
Read the source code documentation [here](https://rubydoc.info/github/avmnu-sng/rspec-tap-formatters/master).
 
## Compatibility
RSpec TAP Formatters supports `MRI 2.3+` and `RSpec 3`.

## Changelog
The changelog is available [here](CHANGELOG.md).

## Copyright
Copyright (c) 2019 Abhimanyu Singh. See [LICENSE.md](LICENSE.md) for
further details.
