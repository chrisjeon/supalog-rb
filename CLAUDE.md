# CLAUDE.md

## Project Overview

Supalog is a Ruby gem that ships logs from Rails applications to the Supalog platform (supalog.dev). It provides a drop-in Rails logger that buffers log entries in memory and flushes them in batches to the Supalog ingest API via a background thread.

**Zero dependencies** — uses only `Net::HTTP` from Ruby stdlib.

## Ingest API

The gem posts to the Supalog ingest API:

- **Endpoint:** `POST /api/logs`
- **Auth:** `X-Api-Key` header with the project's API key
- **Content-Type:** `application/json`
- **Payload:**
```json
{
  "logs": [
    {
      "level": "info",
      "message": "Started GET / for 127.0.0.1",
      "metadata": { "request_id": "abc123" },
      "timestamp": "2026-03-17T14:30:00Z"
    }
  ]
}
```
- **Response:** `201 Created` on success, `401 Unauthorized` on invalid API key

## Architecture

- **`Supalog::Client`** — core class. Holds config (API key, endpoint URL), manages the buffer and background flush thread.
- **`Supalog::Buffer`** — thread-safe in-memory array. Accepts log entries, returns and clears batch on flush.
- **`Supalog::Logger`** — extends or wraps `ActiveSupport::Logger`. Intercepts log calls, writes to the buffer, and optionally passes through to the original logger.
- **`Supalog::Railtie`** — auto-configures in Rails apps. Reads `config.supalog.api_key` and `config.supalog.url`, wires up the logger.

## Expected Usage

```ruby
# config/initializers/supalog.rb
Supalog.configure do |config|
  config.api_key = ENV["SUPALOG_API_KEY"]
  config.url = "https://supalog.dev"       # optional, this is the default
  config.flush_interval = 5                 # seconds, optional, default 5
  config.batch_size = 100                   # optional, default 100
end
```

Once configured, Rails logs automatically flow to Supalog. No other code changes needed.

## Design Constraints

- Zero external dependencies — only `net/http`, `json`, `uri` from stdlib
- Thread-safe buffer (Mutex)
- Background thread flushes on interval OR when batch_size is reached
- Graceful shutdown — flush remaining buffer on `at_exit`
- Silent failures — never raise exceptions that crash the host app. Log errors to STDERR.
- Works with Ruby 3.0+

## Common Commands

- `bundle exec rspec` — run tests
- `bundle exec rake build` — build the gem
- `bundle exec rake install` — install locally
- `bundle exec rake release` — release to RubyGems

## Code Style

- Use double quotes (`"`)
- No external dependencies
- Keep it minimal — this gem should be small and focused
