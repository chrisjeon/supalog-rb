# frozen_string_literal: true

module LogcastSh
  class Buffer
    def initialize(batch_size:, flush_interval:, &on_flush)
      @batch_size = batch_size
      @flush_interval = flush_interval
      @on_flush = on_flush
      @mutex = Mutex.new
      @entries = []
      @stopped = false
      start_flush_thread
    end

    def push(entry)
      should_flush = false

      @mutex.synchronize do
        @entries << entry
        should_flush = @entries.size >= @batch_size
      end

      flush! if should_flush
    end

    def flush!
      batch = nil

      @mutex.synchronize do
        return if @entries.empty?

        batch = @entries.dup
        @entries.clear
      end

      @on_flush.call(batch) if batch
    rescue => e
      $stderr.puts "[LogcastSh] Flush error: #{e.message}"
    end

    def stop
      @stopped = true
      @flush_thread&.join(5)
      @flush_thread = nil
    end

    def size
      @mutex.synchronize { @entries.size }
    end

    private

    def start_flush_thread
      @flush_thread = Thread.new do
        loop do
          sleep @flush_interval
          break if @stopped

          flush!
        end
      end
      @flush_thread.abort_on_exception = false
    end
  end
end
