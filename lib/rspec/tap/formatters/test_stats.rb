# frozen_string_literal: true

module RSpec
  module TAP
    module Formatters
      class TestStats
        attr_reader :data

        def initialize
          @data = {}
        end

        def populate(notification, index)
          metadata = notification.example.metadata[:example_group]
          increment(metadata[:line_number], index)

          while (parent_metadata = metadata[:parent_example_group])
            metadata = parent_metadata
            increment(metadata[:line_number], index)
          end
        end

        private

        def increment(line_number, index)
          @data[line_number] ||= [0, 0, 0, 0]
          @data[line_number][0] += 1
          @data[line_number][index] += 1
        end
      end
    end
  end
end
