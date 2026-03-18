# frozen_string_literal: true

RSpec.describe Supalog::Buffer do
  let(:flushed_batches) { [] }
  let(:buffer) do
    described_class.new(batch_size: 3, flush_interval: 60) do |batch|
      flushed_batches << batch
    end
  end

  after { buffer.stop }

  describe "#push" do
    it "adds entries to the buffer" do
      buffer.push({ "message" => "hello" })
      expect(buffer.size).to eq(1)
    end

    it "flushes when batch_size is reached" do
      3.times { |i| buffer.push({ "message" => "log #{i}" }) }

      sleep 0.1 # give flush a moment
      expect(flushed_batches.size).to eq(1)
      expect(flushed_batches.first.size).to eq(3)
      expect(buffer.size).to eq(0)
    end
  end

  describe "#flush!" do
    it "delivers buffered entries" do
      buffer.push({ "message" => "one" })
      buffer.push({ "message" => "two" })
      buffer.flush!

      expect(flushed_batches.size).to eq(1)
      expect(flushed_batches.first.size).to eq(2)
    end

    it "clears the buffer after flush" do
      buffer.push({ "message" => "one" })
      buffer.flush!
      expect(buffer.size).to eq(0)
    end

    it "does nothing when buffer is empty" do
      buffer.flush!
      expect(flushed_batches).to be_empty
    end
  end

  describe "#size" do
    it "returns current entry count" do
      expect(buffer.size).to eq(0)
      buffer.push({ "message" => "one" })
      expect(buffer.size).to eq(1)
    end
  end

  describe "thread safety" do
    it "handles concurrent pushes without losing entries" do
      large_buffer = described_class.new(batch_size: 10_000, flush_interval: 60) { |_| }
      threads = 10.times.map do |t|
        Thread.new do
          100.times { |i| large_buffer.push({ "message" => "t#{t}-#{i}" }) }
        end
      end
      threads.each(&:join)

      expect(large_buffer.size).to eq(1000)
      large_buffer.stop
    end
  end
end
