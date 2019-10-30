# frozen_string_literal: true

require 'securerandom'

RSpec.describe RSpec::TAP::Formatters::Flat do
  subject(:formatter) { described_class.new(report_output) }

  let(:report_output) { StringIO.new }
  let(:report_printer) { RSpec::TAP::Formatters::Printer.new(report_output) }

  before do
    formatter.instance_variable_set(:@printer, report_printer)
    formatter.instance_variable_set(:@seed, nil)
    formatter.instance_variable_set(:@example_number, 0)
  end

  describe '#seed' do
    let(:seed) { SecureRandom.random_number(10_000) }

    context 'with seed used' do
      let(:notification) { OpenStruct.new(seed: seed, seed_used?: true) }

      it 'updates instance variable' do
        expect { formatter.seed(notification) }
          .to change { formatter.instance_variable_get(:@seed) }
          .from(nil)
          .to(seed)
      end
    end

    context 'without seed used' do
      let(:notification) { OpenStruct.new(seed: seed, seed_used?: false) }

      it 'does not update instance variable' do
        expect { formatter.seed(notification) }
          .not_to change { formatter.instance_variable_get(:@seed) }
      end
    end
  end

  describe '#start' do
    let(:count) { 1 + SecureRandom.random_number(5) }
    let(:notification) { OpenStruct.new(count: count) }

    it 'delegates to printer' do
      allow(report_printer).to receive(:start_output)

      formatter.start(notification)

      expect(report_printer).to have_received(:start_output).with(no_args)
    end
  end

  describe '#start_dump' do
    it 'delegates to printer' do
      allow(report_printer).to receive(:example_progress_dump)

      formatter.start_dump(OpenStruct.new)

      expect(report_printer).to have_received(:example_progress_dump)
        .with(no_args)
    end
  end

  describe '#example_started' do
    let(:example_number) { 1 + SecureRandom.random_number(5) }

    it 'increments example number by one' do
      expect { formatter.example_started(OpenStruct.new) }
        .to change { formatter.instance_variable_get(:@example_number) }
        .by(1)
    end
  end

  describe '#example_passed' do
    let(:example_number) { 1 + SecureRandom.random_number(5) }
    let(:example_status) { :success }
    let(:example_status_index) { 1 }

    let(:description) { 'example-foo' }
    let(:example) { OpenStruct.new(full_description: description) }
    let(:notification) { OpenStruct.new(example: example) }

    before do
      formatter.instance_variable_set(:@example_number, example_number)
    end

    it 'delegates progress report to printer' do
      allow(report_printer).to receive(:example_progress_output)

      formatter.example_passed(notification)

      expect(report_printer).to have_received(:example_progress_output)
        .with(example_status)
    end

    it 'delegates status report to printer' do
      allow(report_printer).to receive(:success_output)

      formatter.example_passed(notification)

      expect(report_printer).to have_received(:success_output)
        .with(description, example_number, 0)
    end
  end

  describe '#example_failed' do
    let(:example_number) { 1 + SecureRandom.random_number(5) }
    let(:example_status) { :failure }
    let(:example_status_index) { 2 }

    let(:description) { 'example-foo' }
    let(:example) { OpenStruct.new(full_description: description) }
    let(:notification) { OpenStruct.new(example: example) }

    before do
      formatter.instance_variable_set(:@example_number, example_number)

      allow(report_printer).to receive(:failure_reason_output)
    end

    it 'delegates progress report to printer' do
      allow(report_printer).to receive(:example_progress_output)

      formatter.example_failed(notification)

      expect(report_printer).to have_received(:example_progress_output)
        .with(example_status)
    end

    it 'delegates status report to printer' do
      allow(report_printer).to receive(:failure_output)

      formatter.example_failed(notification)

      expect(report_printer).to have_received(:failure_output)
        .with(description, example_number, 0)
    end

    it 'delegates reason to printer' do
      formatter.example_failed(notification)

      expect(report_printer).to have_received(:failure_reason_output)
        .with(notification, 1)
    end
  end

  describe '#example_pending' do
    let(:example_number) { 1 + SecureRandom.random_number(5) }
    let(:example_status) { :pending }
    let(:example_status_index) { 3 }

    let(:description) { 'example-foo' }
    let(:example) do
      OpenStruct.new(
        full_description: description,
        execution_result: execution_result
      )
    end
    let(:notification) { OpenStruct.new(example: example) }

    before do
      formatter.instance_variable_set(:@example_number, example_number)
    end

    shared_examples_for 'pending example' do
      it 'delegates progress report to printer' do
        allow(report_printer).to receive(:example_progress_output)

        formatter.example_pending(notification)

        expect(report_printer).to have_received(:example_progress_output)
          .with(example_status)
      end

      it 'delegates status report to printer' do
        allow(report_printer).to receive(:pending_output)

        formatter.example_pending(notification)

        expect(report_printer).to have_received(:pending_output)
          .with(notification, description, example_number, 0)
      end
    end

    context 'with pending' do
      let(:pending_message) { "pending-#{SecureRandom.hex}" }
      let(:directive) { "TODO: #{pending_message}" }
      let(:execution_result) do
        OpenStruct.new(
          pending_message: pending_message,
          example_skipped?: false
        )
      end

      include_examples('pending example')
    end

    context 'with skipped' do
      let(:pending_message) { "skip-#{SecureRandom.hex}" }
      let(:directive) { "SKIP: #{pending_message}" }
      let(:execution_result) do
        OpenStruct.new(
          pending_message: pending_message,
          example_skipped?: true
        )
      end

      include_examples('pending example')
    end
  end

  describe '#message' do
    let(:notification) { OpenStruct.new }

    it 'delegates to printer' do
      allow(report_printer).to receive(:message_output)

      formatter.message(notification)

      expect(report_printer).to have_received(:message_output)
        .with(notification)
    end
  end

  describe '#dump_failures' do
    let(:notification) { OpenStruct.new }

    it 'delegates to printer' do
      allow(report_printer).to receive(:store_failed_examples_summary)

      formatter.dump_failures(notification)

      expect(report_printer).to have_received(:store_failed_examples_summary)
        .with(notification)
    end
  end

  describe '#dump_pending' do
    let(:notification) { OpenStruct.new }

    it 'delegates to printer' do
      allow(report_printer).to receive(:store_pending_examples_summary)

      formatter.dump_pending(notification)

      expect(report_printer).to have_received(:store_pending_examples_summary)
        .with(notification)
    end
  end

  describe '#dump_summary' do
    let(:seed) { 1 + SecureRandom.random_number(10_000) }
    let(:notification) { OpenStruct.new }

    it 'delegates to printer' do
      allow(report_printer).to receive(:summary_output)

      formatter.instance_variable_set(:@seed, seed)
      formatter.dump_summary(notification)

      expect(report_printer).to have_received(:summary_output)
        .with(notification, seed)
    end
  end
end
