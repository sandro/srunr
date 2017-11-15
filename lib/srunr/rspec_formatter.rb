# coding: utf-8
module Srunr

  require "rspec/core/formatters/json_formatter"

  class RSpecFormatter < ::RSpec::Core::Formatters::JsonFormatter

    def initialize(*args)
      $stderr.puts "Formatter init"
      super
    end

    def close(_notification=nil)
      $stderr.puts "close called #{@output_hash.object_id}"
      @output_hash[:examples].each do |e|
        e[:hostname] = Srunr.configuration.hostname
        e[:worker_number] = 1
        @output.report_test(Marshal.dump(e).force_encoding("UTF-8"))
      end
      $stdout.puts "NEXT_TEST"
      $stdout.flush
    end

  end

end
