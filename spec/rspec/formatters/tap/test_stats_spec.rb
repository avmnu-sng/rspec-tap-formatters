# frozen_string_literal: true

RSpec.describe RSpec::Formatters::TAP::TestStats do
  subject(:test_stats) { described_class.new }

  let(:index) { (1..3).to_a.sample }
  let(:example) { OpenStruct.new(metadata: metadata) }
  let(:notification) { OpenStruct.new(example: example) }

  before do
    test_stats.instance_variable_set(:@data, {})
  end

  describe '#populate' do
    context 'when root level test' do
      let(:scoped_id) { '1' }
      let(:metadata) do
        {
          example_group: {
            scoped_id: scoped_id
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

        expect(test_stats.data[scoped_id][0]).to eq(1)
      end

      it 'updates tests status count' do
        test_stats.populate(notification, index)

        expect(test_stats.data[scoped_id][index]).to eq(1)
      end
    end

    context 'when non-root level test' do
      let(:scoped_ids) { %w[1:1:1:1 1:1:1 1:1 1] }
      let(:metadata) do
        {
          example_group: {
            scoped_id: scoped_ids[3],
            parent_example_group: {
              scoped_id: scoped_ids[2],
              parent_example_group: {
                scoped_id: scoped_ids[1],
                parent_example_group: {
                  scoped_id: scoped_ids[0]
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

        scoped_ids.each do |scoped_id|
          expect(test_stats.data[scoped_id][0]).to eq(1)
        end
      end

      it 'updates tests status count' do
        test_stats.populate(notification, index)

        scoped_ids.each do |scoped_id|
          expect(test_stats.data[scoped_id][index]).to eq(1)
        end
      end
    end
  end
end
