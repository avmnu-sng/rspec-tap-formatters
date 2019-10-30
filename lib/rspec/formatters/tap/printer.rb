# frozen_string_literal: true

require_relative '../core_ext/hash'
require_relative '../core_ext/string'

module RSpec
  module Formatters
    module TAP
      class Printer
        EXAMPLE_PROGRESS = {
          success: '.',
          failure: 'F',
          pending: '*'
        }.freeze

        def initialize(output)
          @output = output
          @write_to_file = output.is_a?(File)
          @display_colors = !@write_to_file
          @force_colors = false

          @bailed_out = false

          @failed_examples = ''
          @pending_examples = ''
        end

        def start_output(count = nil)
          return if @bailed_out

          @output.puts('TAP version 13')
          @output.puts('pragma +strict')
          @output.puts("1..#{count}") if count
        end

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

        def group_finished_output(test_stats, padding)
          @output.puts("#{indentation(padding)}1..#{test_stats[0]}")
          stats_output(test_stats, padding)
          @output.puts(colored_line("#{indentation(padding - 1)}}", :detail))
        end

        def example_progress_output(status)
          return unless @write_to_file

          @force_colors = RSpec.configuration.color_enabled?

          $stdout.print(colored_line(EXAMPLE_PROGRESS[status], status))

          @force_colors = false
        end

        def example_progress_dump
          $stdout.puts if @write_to_file
        end

        def success_output(description, example_number, padding)
          line = "ok #{example_number} - #{description}"
          line = colored_line("#{indentation(padding)}#{line}", :success)

          @output.puts(line)
        end

        def failure_output(description, example_number, padding)
          line = "not ok #{example_number} - #{description}"
          line = colored_line("#{indentation(padding)}#{line}", :failure)

          @output.puts(line)
        end

        def failure_reason_output(notification, padding)
          reason =
            case notification.example.execution_result.exception
            when RSpec::Expectations::MultipleExpectationsNotMetError
              multiple_failures_error_and_backtrace(notification)
            else
              failure_error_and_backtrace(notification)
            end

          return if reason.empty?

          failure_diagnostics_output(
            {
              location: notification.example.metadata[:location]
            }.merge(reason).stringify_keys,
            padding
          )
        end

        def pending_output(description, example_number, directive, padding)
          line = "ok #{example_number} - #{description} # #{directive}"
          line = colored_line("#{indentation(padding)}#{line}", :pending)

          @output.puts(line)
        end

        def message_output(notification)
          return if @bailed_out
          return unless RSpec.world.non_example_failure

          bailed_out_message_output(notification)

          @bailed_out = true
        end

        def store_failed_examples_summary(notification)
          return if notification.failure_notifications.empty?

          @failed_examples = notification.fully_formatted_failed_examples
        end

        def store_pending_examples_summary(notification)
          return if notification.pending_examples.empty?

          @pending_examples = notification.fully_formatted_pending_examples
        end

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

        def failure_error_and_backtrace(notification)
          {
            error: failure_error(notification),
            backtrace: failure_backtrace(notification)
          }.compact
        end

        def failure_error(notification)
          uncolorize_lines(notification.message_lines)
            .reject(&:blank?)
            .join("\n")
        end

        def failure_backtrace(notification)
          uncolorize_lines(notification.formatted_backtrace)
            .reject(&:blank?)
            .first(10)
            .join("\n")
        end

        def multiple_failures_error_and_backtrace(notification)
          {
            error: multiple_failures_error(notification)
          }.compact
        end

        def multiple_failures_error(notification)
          exception = notification.example.execution_result.exception

          uncolorize_lines(exception.message.split("\n"))
            .reject(&:blank?)
            .join("\n")
        end

        def failure_diagnostics_output(reason, padding)
          Psych.dump(reason).lines.each do |line|
            @output.print("#{indentation(padding)}#{line}")
          end

          @output.puts("#{indentation(padding)}...")
        end

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

        def bailed_out_report_output
          @output.puts('TAP version 13')
          @output.puts('pragma +strict')
          @output.puts('1..0')
          @output.puts('Bail out!')
        end

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

        def stats_output(test_stats, padding)
          stats = %i[tests passed failed pending]
            .zip(test_stats)
            .to_h
            .reject { |_, value| value.zero? }
            .map { |key, value| "#{key}: #{value}" }
            .join(', ')

          @output.puts("#{indentation(padding)}# #{stats}")
        end

        def dump_failed_examples_summary
          if @write_to_file
            $stdout.puts(@failed_examples)
          else
            @output.puts(@failed_examples)
          end
        end

        def dump_pending_examples_summary
          if @write_to_file
            $stdout.puts(@pending_examples)
          else
            @output.puts(@pending_examples)
          end
        end

        def colored_line(line, status)
          if @force_colors || @display_colors
            RSpec::Core::Formatters::ConsoleCodes.wrap(line, status)
          else
            line
          end
        end

        def uncolorize_lines(lines)
          lines.map { |line| uncolorize_line(line) }
        end

        def uncolorize_line(line)
          return line if line.blank?

          line.gsub(/\e\[(\d+)(;\d+)*m/, '')
        end

        def indentation(padding)
          return unless padding.positive?

          '  ' * padding
        end
      end
    end
  end
end
