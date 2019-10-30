# frozen_string_literal: true

require 'securerandom'

RSpec.shared_context 'when writing to file' do
  before do
    report_printer.instance_variable_set(:@write_to_file, true)
    report_printer.instance_variable_set(:@display_colors, false)
  end
end

RSpec.shared_context 'when not writing to file' do
  before do
    report_printer.instance_variable_set(:@write_to_file, false)
    report_printer.instance_variable_set(:@display_colors, true)
  end
end

RSpec.describe RSpec::Formatters::TAP::Printer do
  subject(:report_printer) { described_class.new(report_output) }

  let(:report_output) { StringIO.new }

  before do
    report_printer.instance_variable_set(:@output, report_output)
    report_printer.instance_variable_set(:@write_to_file, false)
    report_printer.instance_variable_set(:@display_colors, true)
    report_printer.instance_variable_set(:@force_colors, false)
    report_printer.instance_variable_set(:@bailed_out, false)
    report_printer.instance_variable_set(:@failed_examples, '')
    report_printer.instance_variable_set(:@pending_examples, '')
  end

  describe '#start_output' do
    context 'when bailed out' do
      it 'outputs nothing' do
        report_printer.instance_variable_set(:@bailed_out, true)

        expect { report_printer.start_output }.not_to change { report_output }
      end
    end

    context 'when not bailed out' do
      context 'with tests count' do
        let(:count) { 1 + SecureRandom.random_number(5) }

        let(:output_line) do
          <<-OUTPUT.gsub(/^\s+\|/, '').chomp
            |TAP version 13
            |pragma +strict
            |1..#{count}
          OUTPUT
        end

        it 'outputs tap version with tests count' do
          report_printer.start_output(count)

          expect(report_output.string.chomp).to eq(output_line)
        end
      end

      context 'without tests count' do
        let(:output_line) do
          <<-OUTPUT.gsub(/^\s+\|/, '').chomp
            |TAP version 13
            |pragma +strict
          OUTPUT
        end

        it 'outputs tap version with tests count' do
          report_printer.start_output

          expect(report_output.string.chomp).to eq(output_line)
        end
      end
    end
  end

  describe '#group_start_output' do
    let(:description) { 'test-or-group-foo' }
    let(:group) { OpenStruct.new(description: description) }
    let(:notification) { OpenStruct.new(group: group) }

    shared_context 'when root level test' do
      let(:padding) { 0 }
      let(:indentation) { '  ' * padding }

      before do
        report_printer.group_start_output(notification, padding)
      end
    end

    shared_context 'when non-root level test' do
      let(:padding) { 1 + SecureRandom.random_number(5) }
      let(:indentation) { '  ' * padding }

      before do
        report_printer.group_start_output(notification, padding)
      end
    end

    context 'with colorized outputs' do
      before do
        allow(RSpec::Core::Formatters::ConsoleCodes)
          .to receive(:wrap) do |string, status|
          "<#{status}>#{string}</#{status}>"
        end

        report_printer.instance_variable_set(:@display_colors, true)
      end

      context 'when root level test' do
        let(:uncolorized_output_line) do
          "#{indentation}# test: #{description} {"
        end
        let(:output_line) do
          "<detail>#{uncolorized_output_line}</detail>"
        end

        include_context('when root level test')

        it 'outputs test information' do
          expect(report_output.string.chomp).to eq(output_line)
        end

        it 'outputs colorized test information' do
          expect(RSpec::Core::Formatters::ConsoleCodes)
            .to have_received(:wrap)
            .with(a_string_equal_to(uncolorized_output_line), :detail)
        end
      end

      context 'when non-root level test' do
        let(:uncolorized_output_line) do
          "#{indentation}# group: #{description} {"
        end
        let(:output_line) do
          "<detail>#{uncolorized_output_line}</detail>"
        end

        include_context('when non-root level test')

        it 'outputs group information' do
          expect(report_output.string.chomp).to eq(output_line)
        end

        it 'outputs colorized group information' do
          expect(RSpec::Core::Formatters::ConsoleCodes)
            .to have_received(:wrap)
            .with(a_string_equal_to(uncolorized_output_line), :detail)
        end
      end
    end

    context 'without colorized outputs' do
      before do
        allow(RSpec::Core::Formatters::ConsoleCodes)
          .to receive(:wrap).with(String, Symbol)

        report_printer.instance_variable_set(:@display_colors, false)
      end

      context 'when root level test' do
        let(:output_line) { "#{indentation}# test: #{group.description} {" }

        include_context('when root level test')

        it 'outputs test information' do
          expect(report_output.string.chomp).to eq(output_line)
        end

        it 'outputs non-colorized test information' do
          expect(RSpec::Core::Formatters::ConsoleCodes)
            .not_to have_received(:wrap)
        end
      end

      context 'when non-root level test' do
        let(:output_line) { "#{indentation}# group: #{group.description} {" }

        include_context('when non-root level test')

        it 'outputs group information' do
          expect(report_output.string.chomp).to eq(output_line)
        end

        it 'outputs non-colorized group information' do
          expect(RSpec::Core::Formatters::ConsoleCodes)
            .not_to have_received(:wrap)
        end
      end
    end
  end

  describe '#group_finished_output' do
    let(:padding) { 1 + SecureRandom.random_number(5) }
    let(:indentation) { '  ' * padding }
    let(:indentation_one_level_up) { '  ' * (padding - 1) }

    let(:passed) { 1 + SecureRandom.random_number(5) }
    let(:failed) { 1 + SecureRandom.random_number(5) }
    let(:pending) { 0 }
    let(:tests) { passed + failed + pending }
    let(:test_stats) { [tests, passed, failed, pending] }

    context 'with colorized outputs' do
      let(:uncolorized_output_line) { "#{indentation_one_level_up}}" }
      let(:output_line) do
        <<-OUTPUT.gsub(/^\s+\|/, '').chomp
          |#{indentation}1..#{tests}
          |#{indentation}# tests: #{tests}, passed: #{passed}, failed: #{failed}
          |<detail>#{uncolorized_output_line}</detail>
        OUTPUT
      end

      before do
        allow(RSpec::Core::Formatters::ConsoleCodes)
          .to receive(:wrap) do |string, status|
            "<#{status}>#{string}</#{status}>"
          end

        report_printer.instance_variable_set(:@display_colors, true)
        report_printer.group_finished_output(test_stats, padding)
      end

      it 'outputs tests summary' do
        expect(report_output.string.chomp).to eq(output_line)
      end

      it 'outputs colorized tests summary' do
        expect(RSpec::Core::Formatters::ConsoleCodes)
          .to have_received(:wrap)
          .with(a_string_equal_to(uncolorized_output_line), :detail)
      end
    end

    context 'without colorized outputs' do
      let(:output_line) do
        <<-OUTPUT.gsub(/^\s+\|/, '').chomp
          |#{indentation}1..#{tests}
          |#{indentation}# tests: #{tests}, passed: #{passed}, failed: #{failed}
          |#{indentation_one_level_up}}
        OUTPUT
      end

      before do
        allow(RSpec::Core::Formatters::ConsoleCodes)
          .to receive(:wrap).with(String, Symbol)

        report_printer.instance_variable_set(:@display_colors, false)
        report_printer.group_finished_output(test_stats, padding)
      end

      it 'outputs tests summary' do
        expect(report_output.string.chomp).to eq(output_line)
      end

      it 'outputs non-colorized tests summary' do
        expect(RSpec::Core::Formatters::ConsoleCodes)
          .not_to have_received(:wrap)
      end
    end
  end

  describe '#example_progress_output' do
    shared_examples_for 'example progress output' do |char, status|
      context 'when writing to file' do
        include_context('when writing to file')

        context 'with forced colorized outputs' do
          let(:progress_output) { "<#{status}>#{char}</#{status}>" }

          before do
            allow(RSpec::Core::Formatters::ConsoleCodes)
              .to receive(:wrap) do |string, color|
                "<#{color}>#{string}</#{color}>"
              end

            allow(RSpec).to receive(:configuration)
              .with(no_args)
              .and_return(OpenStruct.new(color_enabled?: true))
          end

          it 'outputs example progress' do
            expect { report_printer.example_progress_output(status) }
              .to output(progress_output).to_stdout
          end

          it 'outputs colorized example progress' do
            report_printer.example_progress_output(status)

            expect(RSpec::Core::Formatters::ConsoleCodes)
              .to have_received(:wrap)
              .with(a_string_equal_to(char), status)
          end

          it 'outputs forced colorized example progress' do
            report_printer.example_progress_output(status)

            expect(RSpec).to have_received(:configuration).with(no_args)
          end
        end

        context 'without colorized outputs' do
          let(:progress_output) { char }

          before do
            allow(RSpec::Core::Formatters::ConsoleCodes)
              .to receive(:wrap).with(String, Symbol)

            allow(RSpec).to receive(:configuration)
              .with(no_args).and_return(OpenStruct.new(color_enabled?: false))
          end

          it 'outputs example progress' do
            expect { report_printer.example_progress_output(status) }
              .to output(progress_output).to_stdout
          end

          it 'outputs non-colorized example progress' do
            report_printer.example_progress_output(status)

            expect(RSpec::Core::Formatters::ConsoleCodes)
              .not_to have_received(:wrap)
          end

          it 'outputs non-forced colorized example progress' do
            report_printer.example_progress_output(status)

            expect(RSpec).to have_received(:configuration).with(no_args)
          end
        end
      end

      context 'when not writing to file' do
        before do
          allow(RSpec::Core::Formatters::ConsoleCodes)
            .to receive(:wrap).with(String, Symbol)

          allow(RSpec).to receive(:configuration)
            .with(no_args).and_return(OpenStruct.new)
        end

        include_context('when not writing to file')

        it 'does not output example progress' do
          expect { report_printer.example_progress_output(status) }
            .not_to output.to_stdout
        end

        it 'does not attempt to colorize output' do
          report_printer.example_progress_output(status)

          expect(RSpec::Core::Formatters::ConsoleCodes)
            .not_to have_received(:wrap)
        end

        it 'does not attempt to force colorize output' do
          report_printer.example_progress_output(status)

          expect(RSpec).not_to have_received(:configuration)
        end
      end
    end

    context 'with success progress' do
      include_examples('example progress output', '.', :success)
    end

    context 'with failure progress' do
      include_examples('example progress output', 'F', :failure)
    end

    context 'with success progress' do
      include_examples('example progress output', '*', :pending)
    end
  end

  describe '#example_progress_dump' do
    context 'when writing to file' do
      include_context('when writing to file')

      it 'outputs a blank line' do
        expect { report_printer.example_progress_dump }
          .to output("\n").to_stdout
      end
    end

    context 'without writing to file' do
      include_context('when not writing to file')

      it 'outputs nothing' do
        expect { report_printer.example_progress_dump }
          .not_to output.to_stdout
      end
    end
  end

  describe '#success_output' do
    let(:padding) { 3 }
    let(:indentation) { '  ' * padding }
    let(:description) { 'example-foo' }
    let(:example_number) { 1 + SecureRandom.random_number(5) }

    context 'with colorized outputs' do
      let(:uncolorized_output_line) do
        "#{indentation}ok #{example_number} - #{description}"
      end
      let(:output_line) do
        "<success>#{uncolorized_output_line}</success>"
      end

      before do
        allow(RSpec::Core::Formatters::ConsoleCodes)
          .to receive(:wrap) do |string, status|
            "<#{status}>#{string}</#{status}>"
          end

        report_printer.instance_variable_set(:@display_colors, true)
      end

      it 'outputs example status' do
        report_printer.success_output(description, example_number, padding)

        expect(report_output.string.chomp).to eq(output_line)
      end

      it 'outputs colorized status' do
        report_printer.success_output(description, example_number, padding)

        expect(RSpec::Core::Formatters::ConsoleCodes)
          .to have_received(:wrap)
          .with(a_string_equal_to(uncolorized_output_line), :success)
      end
    end

    context 'without colorized outputs' do
      let(:output_line) do
        "#{indentation}ok #{example_number} - #{description}"
      end

      before do
        allow(RSpec::Core::Formatters::ConsoleCodes).to receive(:wrap)

        report_printer.instance_variable_set(:@display_colors, false)
      end

      it 'outputs example status' do
        report_printer.success_output(description, example_number, padding)

        expect(report_output.string.chomp).to eq(output_line)
      end

      it 'outputs non-colorized example status' do
        report_printer.success_output(description, example_number, padding)

        expect(RSpec::Core::Formatters::ConsoleCodes)
          .not_to have_received(:wrap)
      end
    end
  end

  describe '#failure_output' do
    let(:padding) { 3 }
    let(:indentation) { '  ' * padding }
    let(:description) { 'example-foo' }
    let(:example_number) { 1 + SecureRandom.random_number(5) }

    context 'with colorized outputs' do
      let(:uncolorized_output_line) do
        "#{indentation}not ok #{example_number} - #{description}"
      end
      let(:output_line) do
        "<failure>#{uncolorized_output_line}</failure>"
      end

      before do
        allow(RSpec::Core::Formatters::ConsoleCodes)
          .to receive(:wrap) do |string, status|
            "<#{status}>#{string}</#{status}>"
          end

        report_printer.instance_variable_set(:@display_colors, true)
      end

      it 'outputs example status' do
        report_printer.failure_output(description, example_number, padding)

        expect(report_output.string.chomp).to eq(output_line)
      end

      it 'outputs colorized status' do
        report_printer.failure_output(description, example_number, padding)

        expect(RSpec::Core::Formatters::ConsoleCodes)
          .to have_received(:wrap)
          .with(a_string_equal_to(uncolorized_output_line), :failure)
      end
    end

    context 'without colorized outputs' do
      let(:output_line) do
        "#{indentation}not ok #{example_number} - #{description}"
      end

      before do
        allow(RSpec::Core::Formatters::ConsoleCodes).to receive(:wrap)

        report_printer.instance_variable_set(:@display_colors, false)
      end

      it 'outputs example status' do
        report_printer.failure_output(description, example_number, padding)

        expect(report_output.string.chomp).to eq(output_line)
      end

      it 'outputs non-colorized example status' do
        report_printer.failure_output(description, example_number, padding)

        expect(RSpec::Core::Formatters::ConsoleCodes)
          .not_to have_received(:wrap)
      end
    end
  end

  describe '#failure_reason_output' do
    let(:padding) { 4 }
    let(:indentation) { '  ' * padding }
    let(:indentation_one_level_down) { '  ' * (padding + 1) }
    let(:location) do
      "./spec/foo_spec.rb:#{1 + SecureRandom.random_number(5)}"
    end

    context 'with diagnostics' do
      context 'with aggregate failures' do
        let(:exception) do
          RSpec::Expectations::MultipleExpectationsNotMetError.new
        end
        let(:example) do
          OpenStruct.new(
            execution_result: OpenStruct.new(exception: exception),
            metadata: {
              location: location
            }
          )
        end
        let(:notification) { OpenStruct.new(example: example) }

        let(:failure_diagnostics) do
          diagnostics = <<-DIAGNOSTICS.gsub(/^\s+\|/, '').chomp
          |---
          |location: "#{location}"
          |error: RSpec::Expectations::MultipleExpectationsNotMetError
          |...
          DIAGNOSTICS

          diagnostics.lines
            .map { |line| "#{indentation_one_level_down}#{line}" }
            .join
        end

        it 'outputs failure diagnostics' do
          report_printer.failure_reason_output(notification, padding + 1)

          expect(report_output.string.chomp).to eq(failure_diagnostics)
        end
      end

      context 'without aggregate failures' do
        let(:message_lines) { %w[first_line second_line] }
        let(:formatted_backtrace) { %w[trace_first trace_second trace_third] }
        let(:exception) { RSpec::Expectations::ExpectationNotMetError.new }
        let(:example) do
          OpenStruct.new(
            execution_result: OpenStruct.new(exception: exception),
            metadata: {
              location: location
            }
          )
        end
        let(:notification) do
          OpenStruct.new(
            message_lines: message_lines,
            formatted_backtrace: formatted_backtrace,
            example: example
          )
        end

        let(:failure_diagnostics) do
          diagnostics = <<-DIAGNOSTICS.gsub(/^\s+\|/, '').chomp
          |---
          |location: "#{location}"
          |error: |-
          |  first_line
          |  second_line
          |backtrace: |-
          |  trace_first
          |  trace_second
          |  trace_third
          |...
          DIAGNOSTICS

          diagnostics.lines
            .map { |line| "#{indentation_one_level_down}#{line}" }
            .join
        end

        it 'outputs failure diagnostics' do
          report_printer.failure_reason_output(notification, padding + 1)

          expect(report_output.string.chomp).to eq(failure_diagnostics)
        end
      end
    end

    context 'without diagnostics' do
      let(:example) do
        OpenStruct.new(
          execution_result: OpenStruct.new(
            exception: RSpec::Expectations::ExpectationNotMetError.new
          ),
          metadata: {
            location: location
          }
        )
      end
      let(:notification) do
        OpenStruct.new(
          message_lines: [],
          formatted_backtrace: [],
          example: example
        )
      end

      it 'outputs nothing' do
        expect { report_printer.failure_reason_output(notification, padding) }
          .not_to change { report_output }
      end
    end
  end

  describe '#pending_output' do
    let(:padding) { 3 }
    let(:indentation) { '  ' * padding }
    let(:description) { 'example-foo' }
    let(:example_number) { 1 + SecureRandom.random_number(5) }
    let(:directive) { 'TODO: not yet implemented' }

    context 'with colorized outputs' do
      let(:uncolorized_output_line) do
        "#{indentation}ok #{example_number} - #{description} # #{directive}"
      end
      let(:output_line) do
        "<pending>#{uncolorized_output_line}</pending>"
      end

      before do
        allow(RSpec::Core::Formatters::ConsoleCodes)
          .to receive(:wrap) do |string, status|
            "<#{status}>#{string}</#{status}>"
          end

        report_printer.instance_variable_set(:@display_colors, true)
      end

      it 'outputs example status' do
        report_printer.pending_output(
          description,
          example_number,
          directive,
          padding
        )

        expect(report_output.string.chomp).to eq(output_line)
      end

      it 'outputs colorized status' do
        report_printer.pending_output(
          description,
          example_number,
          directive,
          padding
        )

        expect(RSpec::Core::Formatters::ConsoleCodes)
          .to have_received(:wrap)
          .with(a_string_equal_to(uncolorized_output_line), :pending)
      end
    end

    context 'without colorized outputs' do
      let(:output_line) do
        "#{indentation}ok #{example_number} - #{description} # #{directive}"
      end

      before do
        allow(RSpec::Core::Formatters::ConsoleCodes).to receive(:wrap)

        report_printer.instance_variable_set(:@display_colors, false)
      end

      it 'outputs example status' do
        report_printer.pending_output(
          description,
          example_number,
          directive,
          padding
        )

        expect(report_output.string.chomp).to eq(output_line)
      end

      it 'outputs non-colorized example status' do
        report_printer.pending_output(
          description,
          example_number,
          directive,
          padding
        )

        expect(RSpec::Core::Formatters::ConsoleCodes)
          .not_to have_received(:wrap)
      end
    end
  end

  describe '#message_output' do
    context 'when bailed out' do
      it 'outputs nothing' do
        report_printer.instance_variable_set(:@bailed_out, true)

        expect { report_printer.message_output(OpenStruct.new) }
          .not_to change { report_output }
      end
    end

    context 'when failure inside example' do
      before do
        allow(RSpec).to receive(:world).with(no_args)
          .and_return(OpenStruct.new(non_example_failure: false))
      end

      it 'outputs nothing' do
        expect { report_printer.message_output(OpenStruct.new) }
          .not_to change { report_output }
      end

      it 'verifies failure type' do
        report_printer.message_output(OpenStruct.new)

        expect(RSpec).to have_received(:world)
      end
    end

    context 'when failure outside example' do
      let(:message) do
        <<-MESSAGE.gsub(/^\s+\|/, '').chomp
          |message foo
          |
          |bar message
          |# baz qux message
          |\033[0;31m# colored message quux\033[0m
        MESSAGE
      end
      let(:notification) { OpenStruct.new(message: message) }

      let(:output_line) do
        <<-OUTPUT.gsub(/^\s+\|/, '').chomp
          |TAP version 13
          |pragma +strict
          |1..0
          |Bail out!
          |# message foo
          |# bar message
          |# baz qux message
          |# colored message quux
        OUTPUT
      end

      before do
        allow(RSpec).to receive(:world).with(no_args)
          .and_return(OpenStruct.new(non_example_failure: true))
      end

      it 'outputs message' do
        report_printer.message_output(notification)

        expect(report_output.string.chomp).to eq(output_line)
      end

      it 'verifies failure type' do
        report_printer.message_output(notification)

        expect(RSpec).to have_received(:world)
      end

      it 'marks execution bailed-out' do
        expect { report_printer.message_output(notification) }
          .to change { report_printer.instance_variable_get(:@bailed_out) }
          .from(false)
          .to(true)
      end
    end
  end

  describe '#store_failed_examples_summary' do
    context 'with failed examples' do
      let(:failed_examples) do
        <<-FAILURES.gsub(/^\s+\|/, '').chomp
          |Failure:
          |
          |  1) sample spec fails
          |     Failure/Error: expect(1).to eq(2)
          |
          |       expected: 2
          |            got: 1
          |
          |       (compared using ==)
          |     # ./spec/rspec/string_spec.rb:13
          |  2) sample spec fails twice
          |     Got 2 failures:
          |
          |     2.1) Failure/Error: expect(1).to eq(2)
          |
          |            expected: 2
          |                 got: 1
          |
          |            (compared using ==)
          |          # ./spec/rspec/string_spec.rb:23
          |
          |     2.2) Failure/Error: expect(3).to eq(4)
          |
          |            expected: 4
          |                 got: 3
          |
          |            (compared using ==)
          |          # ./spec/rspec/string_spec.rb:24
        FAILURES
      end
      let(:notification) do
        OpenStruct.new(
          failure_notifications: %i[failure-foo failure-baz],
          fully_formatted_failed_examples: failed_examples
        )
      end

      it 'updates failed examples' do
        expect { report_printer.store_failed_examples_summary(notification) }
          .to change {
            report_printer.instance_variable_get(:@failed_examples)
          }
          .from('')
          .to(failed_examples)
      end
    end

    context 'without failed examples' do
      let(:notification) do
        OpenStruct.new(failure_notifications: [])
      end

      it 'does not update failed examples' do
        expect { report_printer.store_failed_examples_summary(notification) }
          .not_to change {
            report_printer.instance_variable_get(:@failed_examples)
          }
      end
    end
  end

  describe '#store_pending_examples_summary' do
    context 'with pending examples' do
      let(:pending_examples) do
        <<-PENDING.gsub(/^\s+\|/, '').chomp
          |Pending: (Failures listed here are expected and do not affect your suite's status)
          |
          |  1) sample spec without implementation succeeds
          |     # Not yet implemented
          |     # ./spec/rspec/string_spec.rb:8
          |
          |  2) sample spec with unmet expectation also succeeds
          |     # No reason given
          |     Failure/Error: expect(1).to eq(2)
          |
          |       expected: 2
          |            got: 1
          |
          |       (compared using ==)
          |     # ./spec/rspec/string_spec.rb:18
        PENDING
      end
      let(:notification) do
        OpenStruct.new(
          pending_examples: %i[peding-baz pending-qux],
          fully_formatted_pending_examples: pending_examples
        )
      end

      it 'updates pending examples' do
        expect { report_printer.store_pending_examples_summary(notification) }
          .to change {
            report_printer.instance_variable_get(:@pending_examples)
          }
          .from('')
          .to(pending_examples)
      end
    end

    context 'without pending examples' do
      let(:notification) do
        OpenStruct.new(pending_examples: [])
      end

      it 'does not update pending examples' do
        expect { report_printer.store_pending_examples_summary(notification) }
          .not_to change {
            report_printer.instance_variable_get(:@pending_examples)
          }
      end
    end
  end

  describe '#summary_output' do
    context 'when bailed out' do
      it 'outputs nothing' do
        report_printer.instance_variable_set(:@bailed_out, true)

        expect { report_printer.summary_output(OpenStruct.new, nil) }
          .not_to change { report_output }
      end
    end

    context 'when not bailed out' do
      let(:seed) { 1 + SecureRandom.random_number(10_000) }
      let(:tests) { 5 + SecureRandom.random_number(6) }
      let(:examples) { Array.new(tests).map { "example-#{SecureRandom.hex}" } }
      let(:failed) { 2 }
      let(:failed_examples) { examples.sample(2) }
      let(:pending) { 2 }
      let(:pending_examples) { (examples - failed_examples).sample(2) }
      let(:passed) { tests - failed - pending }
      let(:duration) { SecureRandom.random_number.round(6) }
      let(:notification) do
        OpenStruct.new(
          examples: examples,
          failed_examples: failed_examples,
          pending_examples: pending_examples,
          duration: duration
        )
      end

      let(:failed_examples_summary) do
        <<-FAILURES.gsub(/^\s+\|/, '').chomp
          |Failure:
          |
          |  1) sample spec fails
          |     Failure/Error: expect(1).to eq(2)
          |
          |       expected: 2
          |            got: 1
          |
          |       (compared using ==)
          |     # ./spec/rspec/string_spec.rb:13
          |  2) sample spec fails twice
          |     Got 2 failures:
          |
          |     2.1) Failure/Error: expect(1).to eq(2)
          |
          |            expected: 2
          |                 got: 1
          |
          |            (compared using ==)
          |          # ./spec/rspec/string_spec.rb:23
          |
          |     2.2) Failure/Error: expect(3).to eq(4)
          |
          |            expected: 4
          |                 got: 3
          |
          |            (compared using ==)
          |          # ./spec/rspec/string_spec.rb:24
        FAILURES
      end
      let(:pending_examples_summary) do
        <<-PENDING.gsub(/^\s+\|/, '').chomp
          |Pending: (Failures listed here are expected and do not affect your suite's status)
          |
          |  1) sample spec without implementation succeeds
          |     # Not yet implemented
          |     # ./spec/rspec/string_spec.rb:8
          |
          |  2) sample spec with unmet expectation also succeeds
          |     # No reason given
          |     Failure/Error: expect(1).to eq(2)
          |
          |       expected: 2
          |            got: 1
          |
          |       (compared using ==)
          |     # ./spec/rspec/string_spec.rb:18
        PENDING
      end
      let(:failed_and_pending_summary) do
        "#{failed_examples_summary}\n#{pending_examples_summary}"
      end
      let(:output_line) do
        <<-OUTPUT.gsub(/^\s+\|/, '').chomp
          |1..#{tests}
          |# tests: #{tests}, passed: #{passed}, failed: #{failed}, pending: #{pending}
          |# duration: #{duration} seconds
          |# seed: #{seed}
        OUTPUT
      end

      before do
        report_printer.instance_variable_set(
          :@failed_examples,
          failed_examples_summary
        )

        report_printer.instance_variable_set(
          :@pending_examples,
          pending_examples_summary
        )
      end

      context 'when writing to file' do
        include_context('when writing to file')

        it 'outputs tests stats to file' do
          report_printer.summary_output(notification, seed)

          expect(report_output.string.chomp).to eq(output_line)
        end

        it 'outputs failed and pending examples to stdout' do
          expect { report_printer.summary_output(notification, seed) }
            .to output(failed_and_pending_summary + "\n").to_stdout
        end
      end

      context 'when not writing to file' do
        include_context('when not writing to file')

        it 'outputs tests stats, failed and pending examples' do
          report_printer.summary_output(notification, seed)

          expect(report_output.string.chomp)
            .to eq("#{output_line}\n#{failed_and_pending_summary}")
        end
      end
    end
  end
end
