## TAP Specification

### Version line
To indicate that it is TAP 13, the first line of the report is:
```text
TAP version 13
```

### Described class line
The described class is printed as a commented line using the identifier `test`:
```ruby
RSpec.describe String do
end
```
```text
TAP version 13
# test: String {
```

### Example group line
The example group is printed as a commented line using the identifier `group`:
```ruby
RSpec.describe String do
  describe '#empty?' do
  end
end
```
```text
TAP version 13
# test: String {
  # group: #empty? { 
  }
}
```

### Test Line
The test line is the core of TAP. Each test execution is printed as one test line. 
Each test line comprises the following elements:

- **Status**: A passing example is described by `ok` and failing by `not ok`.
Also, any pending examples are considered as not failing.
```ruby
RSpec.describe String do
  describe '#empty?' do
    let(:string) { 'empty?' }

    it 'returns true' do
      expect(string.empty?).to eq(true)
    end
  end
end
```
```text
TAP version 13
# test: String {
  # group: #empty? {
    not ok 
  }
}
```
- **Number**: Example numbers denote the total number of tests executed 
currently. The numbers are scoped to each example group. Example numbers are
followed by the example status.
```ruby
RSpec.describe String do
  describe '#empty?' do
    let(:string) { 'empty?' }

    it 'returns true' do
      expect(string.empty?).to eq(true)
    end
  end
end
```
```text
TAP version 13
# test: String {
  # group: #empty? {
    not ok 1 
  }
}
```
- **Description**: Example description is followed by the example number and
 also separated by a `-`:
```ruby
RSpec.describe String do
  describe '#empty?' do
    let(:string) { 'empty?' }

    it 'returns true' do
      expect(string.empty?).to eq(true)
    end
  end
end
```
```text
TAP version 13
# test: String {
  # group: #empty? {
    not ok 1 - returns true
  }
}
```
- **Directive**: The directive is an optional element that describes a pending 
example. The directive is followed by an example description and also separated 
by a `#`. There are two directives *TODO* and *SKIP*.
```ruby
RSpec.describe String do
  describe '#empty?', skip: 'will debug later' do
    let(:string) { 'empty?' }

    it 'returns true' do
      expect(string.empty?).to eq(true)
    end
  end
end
```
```text
TAP version 13
# test: String {
  # group: #empty? {
    ok 1 - returns true # SKIP: will debug later
  }
}
```

### Stats line
The stats lists total numbers of examples with the total number of passing, 
failing, and pending examples for each example group. The stats line is 
printed as a commented line.
```ruby
RSpec.describe String do
  describe '#empty?' do
    let(:string) { 'empty?' }

    it 'returns true' do
      expect(string.empty?).to eq(true)
    end
  end
end
```
```text
TAP version 13
# test: String {
  # group: #empty? {
    not ok 1 - returns true
  }
  # tests: 1, failed: 1
}
# tests: 1, failed: 1
```

### Failure reason YAML block
The failure reason for examples are represented by one level indented YAML 
block starting with `---` and ending with `...`. The YAML block comprises the 
following attributes:
- `location`: The file name and line number.
- `error`: The failure reason.
- `backtrace`: The backtrace limited to ten lines.
```ruby
RSpec.describe String do
  describe '#present?' do
    let(:string) { ' ' }

    it 'returns false' do
      expect(string.present?).to eq(false)
    end
  end
end
```
```text
TAP version 13
# test: String {
  # group: #present? {
    not ok 1 - returns false
      ---
      location: "./string_spec.rb:5"
      error: |-
        Failure/Error: expect(string.present?).to eq(false)
        NoMethodError:
          undefined method `present?' for String
      backtrace: "./string_spec.rb:5:in `block (4 levels) in <top (required)>'"
      ...
  }
  # tests: 1, failed: 1
}
# tests: 1, failed: 1
```

### Duration line
The duration line is printed as a commented line at the end of execution.
```ruby
RSpec.describe String do
  describe '#empty?' do
    let(:string) { 'empty?' }

    it 'returns true' do
      expect(string.empty?).to eq(true)
    end
  end
end
```
```text
TAP version 13
# test: String {
  # group: #empty? {
    not ok 1 - returns true
  }
  # tests: 1, failed: 1
}
# tests: 1, failed: 1
# duration: 0.026471 seconds
```

### Seed line
The seed line is printed as a commented line at the end of execution.
```ruby
RSpec.describe String do
  describe '#empty?' do
    let(:string) { 'empty?' }

    it 'returns true' do
      expect(string.empty?).to eq(true)
    end
  end
end
```
```text
TAP version 13
# test: String {
  # group: #empty? {
    not ok 1 - returns true
  }
  # tests: 1, failed: 1
}
# tests: 1, failed: 1
# duration: 0.026471 seconds
# seed: 27428
```

### Bail out line
The bail out is a scenario for failure outside of the example, which immediately
stops execution without running any example.
```ruby
RSpec.describe Stirng do
  describe '#empty?' do
    let(:string) { 'empty?' }

    it 'returns true' do
      expect(string.empty?).to eq(true)
    end
  end
end
```
```text
TAP version 13
1..0
Bail out!
# An error occurred while loading ./string_spec.rb.
# Failure/Error:
#   RSpec.describe Stirng do
#     describe '#empty?' do
#       let(:string) { 'empty?' }
#       it 'returns true' do
#         expect(string.empty?).to eq(true)
#       end
#     end
# NameError:
#   uninitialized constant Stirng
#   Did you mean?  String
# ./string_spec.rb:1:in `<top (required)>'
```
