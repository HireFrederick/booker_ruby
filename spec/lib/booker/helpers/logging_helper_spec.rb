require 'spec_helper'

describe Booker::Helpers::LoggingHelper do
  describe '.log_issue' do
    let(:message) { 'message' }
    let(:extra_info) { 'extra' }

    after { described_class.log_issue(message, extra_info) }

    it 'calls the log message block' do
      expect(Booker.config[:log_message]).to receive(:call).with(message, extra_info)
    end

    context 'log message block not set' do
      it 'does not call the block' do
        expect(Booker).to receive(:config).and_return({})
        expect_any_instance_of(Proc).to_not receive(:call)
      end
    end
  end
end
