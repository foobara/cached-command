RSpec.describe Foobara::CachedCommand do
  after do
    FileUtils.rm_f(cached_data_file)
    FileUtils.rm_f(File.dirname(cached_data_file))
  end

  let(:cached_data_file) { "tmp/cached_command/test_module/test_command.json" }
  let(:command_class) do
    stub_module("TestModule")
    stub_class("TestModule::TestCommand", Foobara::Command) do
      def execute
        %w[a b c]
      end
    end

    TestModule::TestCommand.include(described_class)
    TestModule::TestCommand.foobara_cache_expiry = 600
    TestModule::TestCommand.foobara_cache_serializer = Foobara::CommandConnectors::Serializers::AggregateSerializer

    TestModule::TestCommand
  end

  describe "#run" do
    it "caches the result" do
      expect(File.exist?(cached_data_file)).to be false
      outcome = command_class.run

      expect(outcome).to be_success
      result = outcome.result
      expect(result).to eq(%w[a b c])
      expect(File.exist?(cached_data_file)).to be true

      outcome = command_class.run
      expect(outcome).to be_success
      result = outcome.result
      expect(result).to eq(%w[a b c])

      # test loading from disk...
      described_class.cache.clear

      outcome = command_class.run
      expect(outcome).to be_success
      result = outcome.result
      expect(result).to eq(%w[a b c])

      # test expiring
      described_class.cache.transform_values do |value|
        value[:expires_at] -= 1000
      end

      outcome = command_class.run
      expect(outcome).to be_success
      result = outcome.result
      expect(result).to eq(%w[a b c])
    end
  end
end
