# frozen_string_literal: true

require 'rspec/core/formatters/base_formatter'
require_relative 'printer'
require_relative 'test_stats'

module RSpec
  module TAP
    module Formatters
      class Default < RSpec::Core::Formatters::BaseFormatter
        NOTIFICATIONS = %i[
          seed
          start
          start_dump
          example_group_started
          example_group_finished
          example_started
          example_passed
          example_failed
          example_pending
          message
          dump_failures
          dump_pending
          dump_summary
        ].freeze

        RSpec::Core::Formatters.register(self, *NOTIFICATIONS)

        def initialize(output)
          super

          @printer = Printer.new(output)
          @test_stats = TestStats.new
          @seed = nil
          @level = 0
          @example_number = 0
        end

        def seed(notification)
          @seed = notification.seed if notification.seed_used?
        end

        def start(notification)
          super

          @printer.start_output
        end

        def start_dump(_notification)
          @printer.example_progress_dump
        end

        def example_group_started(notification)
          @printer.group_start_output(notification, @level)

          @level += 1
          @example_number = 0
        end

        def example_group_finished(notification)
          @printer.group_finished_output(
            @test_stats.data[notification.group.metadata[:line_number]],
            @level
          )

          @level -= 1 if @level.positive?
          @test_stats = TestStats.new if @level.zero?
        end

        def example_started(_notification)
          @example_number += 1
        end

        def example_passed(notification)
          @test_stats.populate(notification, 1)
          @printer.example_progress_output(:success)
          @printer.success_output(
            notification.example.description.strip,
            @example_number,
            @level
          )
        end

        def example_failed(notification)
          @test_stats.populate(notification, 2)
          @printer.example_progress_output(:failure)
          @printer.failure_output(
            notification.example.description.strip,
            @example_number,
            @level
          )
          @printer.failure_reason_output(notification, @level + 1)
        end

        def example_pending(notification)
          @test_stats.populate(notification, 3)
          @printer.example_progress_output(:pending)
          @printer.pending_output(
            notification,
            notification.example.description.strip,
            @example_number,
            @level
          )
        end

        def message(notification)
          @printer.message_output(notification)
        end

        def dump_failures(notification)
          @printer.store_failed_examples_summary(notification)
        end

        def dump_pending(notification)
          @printer.store_pending_examples_summary(notification)
        end

        def dump_summary(notification)
          @printer.summary_output(notification, @seed)
        end
      end
    end
  end
end
