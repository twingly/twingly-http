# frozen_string_literal: true

begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:spec) do |task|
    seed      = ENV.fetch("RSPEC_SEED")      { "" }
    formatter = ENV.fetch("RSPEC_FORMATTER") { "documentation" }

    task.rspec_opts = "--order rand:#{seed} --format #{formatter}"
  end
rescue LoadError
  warn "Could not require RSpec gem"
end

begin
  require "rubocop/rake_task"

  desc "Run RuboCop"
  RuboCop::RakeTask.new(:rubocop).tap do |task|
    task.options = %w[--parallel]
  end
rescue LoadError
  warn "Rakefile could not require RuboCop gem"
end

task default: %i[spec rubocop]
