require "srunr/version"

module Srunr
  autoload :Cli, "srunr/cli"
  autoload :CommandParser, "srunr/cli"
  autoload :Loader, "srunr/loader"
  autoload :Runner, "srunr/runner"
  autoload :RSpecFormatter, "srunr/rspec_formatter"
  autoload :OutputStream, "srunr/output_stream"

  def self.benchmark(msg=nil)
    location = caller_locations(2,1)[0]
    $stdout.print "#{msg.sub(/([^\s])$/, '\1 ')}#{location}... "
    start_time = Time.now
    yield
  ensure
    $stdout.puts "completed in #{Time.now - start_time}s"
  end

  def self.quiet_benchmark
    location = caller_locations(2,1)[0]
    start_time = Time.now
    yield
  ensure
    $stderr.puts "#{location} completed in #{Time.now - start_time}s"
  end
end
