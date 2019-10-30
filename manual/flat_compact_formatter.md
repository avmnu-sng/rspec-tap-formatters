## Flat Compact Formatter

The flat compact formatter is implemented on top of the [flat formatter](flat_formatter.md), and it 
omits the failure reason YAML block. Configure the `--format` option to use this format:
```sh
--format RSpec::TAP::Formatters::FlatCompact
```

The generated report for [String spec](string_spec.md):
```text
TAP version 13
ok 1 - String#present? when whitespaces only returns false
not ok 2 - String#present? when nil returns false
ok 3 - String#present? when whitespaces and other characters returns true
ok 4 - String#squish squishes # SKIP: it is Ruby not Rails
ok 5 - String#blank? returns true # TODO: need to implement blank? for NilClass
not ok 6 - String#blank? returns false
1..6
# tests: 6, passed: 2, failed: 2, pending: 2
# duration: 0.010135 seconds
# seed: 2708
```
