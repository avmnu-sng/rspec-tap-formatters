# frozen_string_literal: true

RSpec.describe RSpec::TAP::Formatters::TestStats do
  subject(:test_stats) { described_class.new }

  let(:index) { (1..3).to_a.sample }
  let(:example) { OpenStruct.new(metadata: metadata) }
  let(:notification) { OpenStruct.new(example: example) }

  before do
    test_stats.instance_variable_set(:@data, {})
  end

  describe '#populate' do
    context 'when root level test' do
      let(:line_number) { 1 + SecureRandom.random_number(5) }
      let(:metadata) do
        {
          example_group: {
            line_number: line_number
          }
        }
      end

      it 'creates one data point' do
        expect { test_stats.populate(notification, index) }
          .to change { test_stats.data.size }
          .from(0)
          .to(1)
      end

      it 'updates total tests count' do
        test_stats.populate(notification, index)

        expect(test_stats.data[line_number][0]).to eq(1)
      end

      it 'updates tests status count' do
        test_stats.populate(notification, index)

        expect(test_stats.data[line_number][index]).to eq(1)
      end
    end

    context 'when non-root level test' do
      let(:line_numbers) do
        numbers = Set.new
        numbers << 1 + SecureRandom.random_number(100) while numbers.size != 4
        numbers.sort
      end
      let(:metadata) do
        {
          example_group: {
            line_number: line_numbers[3],
            parent_example_group: {
              line_number: line_numbers[2],
              parent_example_group: {
                line_number: line_numbers[1],
                parent_example_group: {
                  line_number: line_numbers[0]
                }
              }
            }
          }
        }
      end

      it 'creates four data points' do
        expect { test_stats.populate(notification, index) }
          .to change { test_stats.data.size }
          .from(0)
          .to(4)
      end

      it 'updates total tests count' do
        test_stats.populate(notification, index)

        line_numbers.each do |line_number|
          expect(test_stats.data[line_number][0]).to eq(1)
        end
      end

      it 'updates tests status count' do
        test_stats.populate(notification, index)

        line_numbers.each do |line_number|
          expect(test_stats.data[line_number][index]).to eq(1)
        end
      end
    end
  end
end
