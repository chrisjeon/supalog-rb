# Supalog

[![Gem Version](https://badge.fury.io/rb/supalog.svg)](https://rubygems.org/gems/supalog)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Ship your Rails logs to [Supalog](https://www.supalog.dev) with zero external dependencies.

Supalog is a drop-in Rails logger that buffers log entries in memory and flushes them in batches to the Supalog ingest API via a background thread. Your existing Rails logging continues to work as normal — Supalog simply taps into it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "supalog"
```

Then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install supalog
```

## Quick Start

1. Get your API key from [supalog.dev](https://www.supalog.dev)

2. Create an initializer:

```ruby
# config/initializers/supalog.rb
Supalog.configure do |config|
  config.api_key = ENV["SUPALOG_API_KEY"]
end
```

That's it. Your Rails logs now flow to Supalog automatically — no other code changes needed.

## Configuration

| Option           | Default                      | Description                                          |
|------------------|------------------------------|------------------------------------------------------|
| `api_key`        | `nil`                        | **Required.** Your Supalog project API key.          |
| `url`            | `"https://www.supalog.dev"`  | Supalog ingest endpoint.                             |
| `flush_interval` | `5`                          | Seconds between background flushes.                  |
| `batch_size`     | `100`                        | Max entries buffered before an immediate flush.       |

```ruby
Supalog.configure do |config|
  config.api_key        = ENV["SUPALOG_API_KEY"]
  config.url            = "https://www.supalog.dev"  # default
  config.flush_interval = 5                          # seconds, default
  config.batch_size     = 100                        # default
end
```

## How It Works

1. **Intercepts** — Wraps `Rails.logger` to capture every log call.
2. **Buffers** — Stores entries in a thread-safe in-memory array.
3. **Flushes** — A background thread sends batches to the Supalog API every `flush_interval` seconds, or immediately when `batch_size` is reached.
4. **Passes through** — All logs still go to the original Rails logger, so your existing output (console, file, etc.) is unaffected.
5. **Shuts down gracefully** — Remaining buffered logs are flushed on process exit via `at_exit`.

Supalog never raises exceptions that could crash your application. Transport errors are silently logged to `STDERR`.

## Requirements

- Ruby >= 3.0
- Rails (auto-configures via Railtie)
- **Zero external dependencies** — uses only Ruby stdlib (`net/http`, `json`, `uri`)

## Development

```bash
# Run the test suite
bundle exec rspec

# Build the gem locally
bundle exec rake build

# Install the gem locally
bundle exec rake install
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/chrisjeon/supalog-rb).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
