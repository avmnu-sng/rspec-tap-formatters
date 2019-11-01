# frozen_string_literal: true

module RSpec
  module TAP
    module Formatters
      # Test stats calculator
      class TestStats
        # @!attribute
        # @return [Hash<Integer, Array<Integer, 4>>] example stats
        attr_reader :data

        def initialize
          @data = {}
        end

        # Populates total number of examples and one of
        # passing, failing, and, pending example.
        # Traverses bottom up to populate each of the parent example group
        # stats.
        #
        # @param notification [ExampleNotification] example notification
        # @param index [Integer] the example status index
        #   (1 - Passing, 2 - Failing, 3 - Pending)
        def populate(notification, index)
          metadata = notification.example.metadata[:example_group]
          increment(metadata[:line_number], index)

          while (parent_metadata = metadata[:parent_example_group])
            metadata = parent_metadata
            increment(metadata[:line_number], index)
          end
        end

        private

        # Increments the stats for a line number and example status.
        #
        # @param line_number [Integer] the example or group line number
        # @param index [Integer] the example status index
        #   (1 - Passing, 2 - Failing, 3 - Pending)
        def increment(line_number, index)
          @data[line_number] ||= [0, 0, 0, 0]
          @data[line_number][0] += 1
          @data[line_number][index] += 1
        end
      end
    end
  end
end
