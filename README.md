# Supalog

Ship your Rails logs to [Supalog](https://www.supalog.dev) with zero dependencies.

Supalog is a drop-in Rails logger that buffers log entries in memory and flushes them in batches to the Supalog ingest API via a background thread.

## Installation

Add to your Gemfile:

```ruby
gem "supalog"
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install supalog
```

## Usage

Create an initializer in your Rails app:

```ruby
# config/initializers/supalog.rb
Supalog.configure do |config|
  config.api_key = ENV["SUPALOG_API_KEY"]
  config.url = "https://www.supalog.dev"       # optional, this is the default
  config.flush_interval = 5                     # seconds, optional, default 5
  config.batch_size = 100                       # optional, default 100
end
```

That's it. Once configured, your Rails logs automatically flow to Supalog. No other code changes needed.

## How It Works

- Wraps `Rails.logger` to intercept all log calls
- Buffers entries in a thread-safe in-memory array
- Flushes to the Supalog ingest API on a background thread (every `flush_interval` seconds or when `batch_size` is reached)
- Passes logs through to the original Rails logger so your existing logging is unaffected
- Gracefully flushes remaining logs on process exit
- Never raises exceptions that could crash your app — errors are silently logged to STDERR

## Requirements

- Ruby 3.0+
- Rails (uses `ActiveSupport::Logger`)
- No external dependencies — only Ruby stdlib (`net/http`, `json`, `uri`)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
