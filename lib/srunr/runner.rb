# coding: utf-8
module Srunr
  class Runner
    MY_STDOUT = File.expand_path("srunr.stdout", Dir.pwd)
    MY_STDERR = File.expand_path("srunr.stderr", Dir.pwd)

    def initialize
      @my_stdout = File.open(MY_STDOUT, "wb")
      @my_stderr = File.open(MY_STDERR, "wb")
      at_exit  do
        @my_stdout.close
        @my_stderr.close
      end
      @o_stream = OutputStream.new(@my_stdout)
      @e_Stream = OutputStream.new(@my_stderr)
    end

    def load_all
      loader.load_all(@o_stream, @e_stream)
    end

    def before_suite
      load_all
      ::RSpec.configuration.run_hook(:before, :suite)
    end

    def after_suite
      load_all
      ::RSpec.configuration.run_hook(:after, :suite)
    end

    # run_test ./spec/api/api_spec.rb:16
    def run_test(test)
      test = test.first
      load_all

      Srunr.benchmark("running #{test}") do
        good_run test
      end
    end

    def good_run(test)
      ::RSpec.configuration.reset
      ::RSpec.configuration.add_formatter(Srunr::RSpecFormatter)
      examples_or_groups = loader.all_specs[test]
      if examples_or_groups.nil?
        $stderr.puts "Could not find #{test}"
        return
      end
      ::RSpec.configuration.reporter.report(1, nil) do |reporter|
        examples_or_groups.each do |example_or_group|
          if example_or_group.respond_to?(:example_group)
            example = example_or_group
            instance = example.example_group.new
            example.run instance, reporter
          else
            example_or_group.run(reporter)
          end
        end
      end
    end

    def loader
      @loader ||= Loader.new
    end

  end
end
