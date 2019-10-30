## Formatters

RSpec TAP Formatters supports four formats. Each formatter will print any 
deprecation warnings and failures and pending examples summary at the end of 
the execution. This additional data is not part of the TAP report.

Each formatter respects the color configuration for the execution and only 
prints colored output when enabled. However, writing to a file will never use 
colors.

When writing the report to a file, each formatter will print progress status 
on the standard output:
- `.` denotes a passing example.
- `F` denotes a failing example.
- `*` denotes a pending example.

### Default
The default formatter reports example groups with proper indentation and adds 
failure reason YAML blocks for each failed example. Configure the `--format`
option to use this format:
```sh
--format RSpec::TAP::Formatters::Default
```

### Compact
The compact formatter is implemented on top of the default formatter, and it 
omits the failure reason YAML block. Configure the `--format`
option to use this format:
```sh
--format RSpec::TAP::Formatters::Compact
```

### Flat
The flat formatter does not report example groups. It only lists the examples 
executed and adds the failure reason YAML block for each failed example.
Configure the `--format` option to use this format:
```sh
--format RSpec::TAP::Formatters::Flat
```

### Flat Compact
The flat compact formatter is implemented on top of the flat formatter, and it 
omits the failure reason YAML block. Configure the `--format` option to use this format:
```sh
--format RSpec::TAP::Formatters::FlatCompact
```
