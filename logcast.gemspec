# frozen_string_literal: true

require_relative "lib/logcast_sh/version"

Gem::Specification.new do |spec|
  spec.name = "logcast-sh"
  spec.version = LogcastSh::VERSION
  spec.authors = ["Chris Jeon"]
  spec.email = ["chris@typefast.co"]

  spec.summary = "Ship Rails logs to the Logcast platform"
  spec.description = "A drop-in Rails logger that buffers log entries and flushes them in batches to the Logcast ingest API via a background thread."
  spec.homepage = "https://www.logcast.sh"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/chrisjeon/logcast-rb"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
