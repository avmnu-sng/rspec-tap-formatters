You can specify the format as the command argument:
```sh
bundle exec rspec --format RSpec::TAP::Formatters::Default
```

To write to file, provide the `--out` argument:
```sh
bundle exec rspec --format RSpec::TAP::Formatters::Default --out report.tap
```

You can also configure the `.rspec` file:
```ruby
# other configurations
--format RSpec::TAP::Formatters::Default
--out report.tap
```
