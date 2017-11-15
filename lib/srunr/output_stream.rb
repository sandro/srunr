# coding: utf-8
module Srunr
  class OutputStream

    def initialize(destination=$stdout)
      @destination = destination
    end

    def noop(m, *args)
      $stderr.puts ["no-op called", m, args].inspect
    end

    def puts(*args)
      noop __method__, args
    end

    def write(*args)
      noop __method__, args
    end

    def report_test(example)
      $stdout.puts "Srunr reporting example"
      $stdout.puts "#{example.bytesize} #{example.size} #{Marshal.load(example)}\n#{example}\n"
      $stdout.flush
      @destination.puts example.bytesize
      @destination.write example
      @destination.flush
    end

    def method_missing(m, *args)
      $stderr.puts ["method_missing", m, args].inspect
    end
  end
end
