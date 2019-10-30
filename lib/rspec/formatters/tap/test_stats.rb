# frozen_string_literal: true

module RSpec
  module Formatters
    module TAP
      class TestStats
        attr_reader :data

        def initialize
          @data = {}
        end

        def populate(notification, index)
          metadata = notification.example.metadata[:example_group]
          increment(metadata[:scoped_id], index)

          while (parent_metadata = metadata[:parent_example_group])
            metadata = parent_metadata
            increment(metadata[:scoped_id], index)
          end
        end

        private

        def increment(scoped_id, index)
          @data[scoped_id] ||= [0, 0, 0, 0]
          @data[scoped_id][0] += 1
          @data[scoped_id][index] += 1
        end
      end
    end
  end
end
