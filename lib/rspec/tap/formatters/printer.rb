# frozen_string_literal: true

require 'rspec/core/formatters/console_codes'
require_relative 'core_ext/hash'
require_relative 'core_ext/string'

module RSpec
  module TAP
    module Formatters
      # TAP report printer
      class Printer
        # Example status progress report characters
        EXAMPLE_PROGRESS = {
          success: '.',
          failure: 'F',
          pending: '*'
        }.freeze

        # Constructor
        #
        # @param output [StringIO, File] output stream
        def initialize(output)
          @output = output
          @write_to_file = output.is_a?(File)
          @display_colors = !@write_to_file
          @force_colors = false

          @bailed_out = false

          @failed_examples = ''
          @pending_examples = ''
        end

        # Handler for formatter +start+ notification.
        def start_output
          return if @bailed_out

          @output.puts('TAP version 13')
        end

        # Handler for formatter +example_group_started+ notification.
        #
        # @param notification [ExampleNotification] example notification
        # @param padding [Integer] indentation width
        def group_start_output(notification, padding)
          description = notification.group.description.strip

          line =
            if padding.zero?
              "#{indentation(padding)}# test: #{description} {"
            else
              "#{indentation(padding)}# group: #{description} {"
            end

          @output.puts(colored_line(line, :detail))
        end

        # Handler for formatter +example_group_finished+ notification.
        #
        # @param test_stats [Array<Integer>] stats for the example group
        # @param padding [Integer] indentation width
        #
        # @see stats_output
        def group_finished_output(test_stats, padding)
          @output.puts("#{indentation(padding)}1..#{test_stats[0]}")
          stats_output(test_stats, padding)
          @output.puts(colored_line("#{indentation(padding - 1)}}", :detail))
        end

        # Prints example progress when writing to a file.
        # +.+ for passing, +F+ for failing, and `*` for pending example.
        #
        # @param status [Symbol] example status
        def example_progress_output(status)
          return unless @write_to_file

          @force_colors = RSpec.configuration.color_enabled?

          $stdout.print(colored_line(EXAMPLE_PROGRESS[status], status))

          @force_colors = false
        end

        # Handler for formatter +start_dump+ notification.
        def example_progress_dump
          $stdout.puts if @write_to_file
        end

        # Handler for formatter +example_passed+ notification.
        #
        # @param description [String] example description
        # @param example_number [Integer] example number
        # @param padding [Integer] indentation width
        def success_output(description, example_number, padding)
          line = "ok #{example_number} - #{description}"
          line = colored_line("#{indentation(padding)}#{line}", :success)

          @output.puts(line)
        end

        # Handler for formatter +example_failed+ notification.
        #
        # @param description [String] example description
        # @param example_number [Integer] example number
        # @param padding [Integer] indentation width
        def failure_output(description, example_number, padding)
          line = "not ok #{example_number} - #{description}"
          line = colored_line("#{indentation(padding)}#{line}", :failure)

          @output.puts(line)
        end

        # Prints failure reason YAML block
        # The aggregate failures are not reported for RSpec version
        # before +3.3.0+.
        #
        # @param notification [ExampleNotification] example notification
        # @param padding [Integer] indentation width
        def failure_reason_output(notification, padding)
          rspec_version = Gem::Version.new(RSpec::Core::Version::STRING)
          reason =
            if rspec_version >= Gem::Version.new('3.3.0')
              failure_reason_for_and_post_3_3_0(notification)
            else
              failure_reason_pre_3_3_0(notification)
            end

          return if reason.empty?

          failure_diagnostics_output(
            {
              location: notification.example.metadata[:location]
            }.merge(reason).stringify_keys,
            padding
          )
        end

        # Handler for formatter +example_pending+ notification.
        #
        # @param description [String] example description
        # @param example_number [Integer] example number
        # @param padding [Integer] indentation width
        def pending_output(notification, description, example_number, padding)
          directive = pending_example_directive(notification)
          line = "ok #{example_number} - #{description} # #{directive}"
          line = colored_line("#{indentation(padding)}#{line}", :pending)

          @output.puts(line)
        end

        # Handler for formatter +message+ notification.
        #
        # @param notification [ExampleNotification] example notification
        def message_output(notification)
          return if @bailed_out
          return unless RSpec.world.non_example_failure

          bailed_out_message_output(notification)

          @bailed_out = true
        end

        # Handler for formatter +dump_failures+ notification.
        #
        # @param notification [ExampleNotification] example notification
        def store_failed_examples_summary(notification)
          return if notification.failure_notifications.empty?

          @failed_examples = notification.fully_formatted_failed_examples
        end

        # Handler for formatter +dump_pending+ notification.
        #
        # @param notification [ExampleNotification] example notification
        def store_pending_examples_summary(notification)
          return if notification.pending_examples.empty?

          @pending_examples = notification.fully_formatted_pending_examples
        end

        # Handler for formatter +dump_summary+ notification.
        #
        # @param notification [ExampleNotification] example notification
        # @param seed [Integer] used seed
        def summary_output(notification, seed)
          return if @bailed_out

          @output.puts("1..#{notification.examples.size}")

          return if notification.examples.size.zero?

          execution_stats_output(notification)

          @output.puts("# seed: #{seed}") if seed

          dump_failed_examples_summary if @failed_examples.present?
          dump_pending_examples_summary if @pending_examples.present?
        end

        private

        # Provides failure reason for RSpec version before +3.3.0+.
        #
        # @param notification [ExampleNotification] example notification
        # @return [Hash<Symbol, String>] +error+ and +backtrace+ for
        #   the YAML block
        def failure_reason_pre_3_3_0(notification)
          failure_error_and_backtrace(notification)
        end

        # Provides failure reason for RSpec version after +3.3.0+.
        #
        # @param notification [ExampleNotification] example notification
        # @return [Hash<Symbol, String>] +error+ and +backtrace+
        #   for the YAML block
        def failure_reason_for_and_post_3_3_0(notification)
          case notification.example.execution_result.exception
          when RSpec::Expectations::MultipleExpectationsNotMetError
            multiple_failures_error_and_backtrace(notification)
          else
            failure_error_and_backtrace(notification)
          end
        end

        # Provides failure error and backtrace.
        #
        # @param notification [ExampleNotification] example notification
        # @return [Hash<Symbol, String>] +error+ and +backtrace+
        #   for the YAML block
        def failure_error_and_backtrace(notification)
          {
            error: failure_error(notification),
            backtrace: failure_backtrace(notification)
          }.compact
        end

        # Provides failure error.
        #
        # @param notification [ExampleNotification] example notification
        # @return [String] failure error
        def failure_error(notification)
          message_lines = notification.message_lines

          return if message_lines.empty?

          uncolorize_lines(message_lines)
            .reject(&:blank?)
            .join("\n")
        end

        # Provides failure backtrace.
        #
        # @param notification [ExampleNotification] example notification
        # @return [String] failure backtrace
        def failure_backtrace(notification)
          formatted_backtrace = notification.formatted_backtrace

          return if formatted_backtrace.empty?

          uncolorize_lines(formatted_backtrace)
            .reject(&:blank?)
            .first(10)
            .join("\n")
        end

        # Provides aggregate failure error.
        #
        # @param notification [ExampleNotification] example notification
        # @return [Hash<Symbol, String>] +error+ for the YAML block
        def multiple_failures_error_and_backtrace(notification)
          {
            error: multiple_failures_error(notification)
          }.compact
        end

        # Provides aggregate failure error.
        #
        # @param notification [ExampleNotification] example notification
        # @return [String] aggregate failure error
        def multiple_failures_error(notification)
          message = notification.example.execution_result.exception.message

          return if message.blank?

          uncolorize_lines(message.split("\n"))
            .reject(&:blank?)
            .join("\n")
        end

        # Prints failure error YAML block.
        #
        # @param reason [Hash<String, String>] failure reason hash
        #   for +location+, +error+, and +backtrace+
        # @param padding [Integer] indentation width
        def failure_diagnostics_output(reason, padding)
          Psych.dump(reason).lines.each do |line|
            @output.print("#{indentation(padding)}#{line}")
          end

          @output.puts("#{indentation(padding)}...")
        end

        # Finds the directive for pending example.
        #
        # @param notification [ExampleNotification] example notification
        # @return [String] directive +SKIP+ or +TODO+
        def pending_example_directive(notification)
          execution_result = notification.example.execution_result
          could_be_skipped = execution_result.respond_to?(:example_skipped?)

          if could_be_skipped && execution_result.example_skipped?
            "SKIP: #{execution_result.pending_message}"
          else
            "TODO: #{execution_result.pending_message}"
          end
        end

        # Prints failure reason outside of example.
        # It is the only bail out scenario.
        #
        # @param notification [ExampleNotification] example notification
        def bailed_out_message_output(notification)
          bailed_out_report_output

          uncolorize_lines(notification.message.split("\n")).each do |line|
            next if line.blank?

            if line.start_with?('#')
              @output.puts("# #{line.chars.drop(1).join.strip}")
            else
              @output.puts("# #{line}")
            end
          end
        end

        # Prints required TAP lines for bailed out scenario.
        def bailed_out_report_output
          @output.puts('TAP version 13')
          @output.puts('1..0')
          @output.puts('Bail out!')
        end

        # Prints example stats and duration for the entire execution.
        #
        # @param notification [ExampleNotification] example notification
        def execution_stats_output(notification)
          test_stats = [
            notification.examples.size,
            0,
            notification.failed_examples.size,
            notification.pending_examples.size
          ]
          test_stats[1] = test_stats[0] - test_stats.drop(1).reduce(:+)

          stats_output(test_stats, 0)

          @output.puts("# duration: #{notification.duration} seconds")
        end

        # Prints example stats.
        #
        # @param test_stats [Array<Integer>] stats for the example group
        # @param padding [Integer] indentation width
        def stats_output(test_stats, padding)
          stats = %i[tests passed failed pending]
            .zip(test_stats)
            .to_h
            .reject { |_, value| value.zero? }
            .map { |key, value| "#{key}: #{value}" }
            .join(', ')

          @output.puts("#{indentation(padding)}# #{stats}")
        end

        # Prints failed examples list.
        # It is not included in the TAP report.
        def dump_failed_examples_summary
          if @write_to_file
            $stdout.puts(@failed_examples)
          else
            @output.puts(@failed_examples)
          end
        end

        # Prints pending examples list.
        # It is not included in the TAP report.
        def dump_pending_examples_summary
          if @write_to_file
            $stdout.puts(@pending_examples)
          else
            @output.puts(@pending_examples)
          end
        end

        # Converts string to colored string.
        #
        # @param line [String] line to print
        # @param status [Symbol] status for color
        #   (:detail, :success, :failure, and :pending)
        # @return [String] colored string
        def colored_line(line, status)
          if @force_colors || @display_colors
            RSpec::Core::Formatters::ConsoleCodes.wrap(line, status)
          else
            line
          end
        end

        # Converts array of colored strings to uncolored string
        #
        # @param lines [Array<String>] lines to uncolor
        # @return [Array<String>] uncolored lines
        def uncolorize_lines(lines)
          lines.map { |line| uncolorize_line(line) }
        end

        # Converts string to uncolored line.
        # It strips ANSI escape sequences +\033[XXXm+.
        #
        # @example
        #   uncolorize_line('\033[0;31mcolored line\033[0m')
        #   #=> 'colored line'
        #
        # @param line [String] line to print
        # @return [String] uncolored line
        def uncolorize_line(line)
          return line if line.blank?

          line.gsub(/\e\[(\d+)(;\d+)*m/, '')
        end

        # Computes the indentation width by padding.
        # The default indentation width is +2+.
        #
        # @param padding [Integer] indentation width
        # @return [String] string of whitespaces
        def indentation(padding)
          return unless padding.positive?

          '  ' * padding
        end
      end
    end
  end
end
