A sample `String` spec to display each formatter result.

```ruby
# frozen_string_literal: true

RSpec.describe Stirng do
  describe '#present?' do
    context 'when nil' do
      let(:string) { nil }

      it 'returns false' do
        expect(string.present?).to eq(false)
      end
    end

    context 'when whitespaces only' do
      let(:string) { '   ' }

      it 'returns false' do
        expect(string.present?).to eq(false)
      end
    end

    context 'when whitespaces and other characters' do
      let(:string) { ' TAP format is cool! ' }

      it 'returns true' do
        expect(string.present?).to eq(true)
      end
    end
  end

  describe '#blank?', :aggregate_failures do
    it 'returns false' do
      string = 'TAP '

      expect(string.blank?).to eq(true)
      expect(string.strip.blank?).to eq(true)
    end

    it 'returns true', pending: 'need to implement blank? for NilClass' do
      string = nil

      expect(string.blank?).to eq(true)
    end
  end

  describe '#squish' do
    it 'squishes', skip: 'it is Ruby not Rails' do
      string = <<-STRING.gsub(/^\s+\|/, '').chomp
        |Hello
        |   Hi
        |Hey
      STRING

      expect(string.squish).to eq('Hello Hi Hey')
    end
  end
end
```
