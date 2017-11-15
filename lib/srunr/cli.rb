module Srunr
  class CommandParser
    COMMANDS = {
      run_test: :run_test,
      hostname: :hostname
    }

    def initialize
      @runner = Runner.new
    end

    def parse(val)
      command, args = val.split(" ", 2)
      method = COMMANDS[command.to_sym]
      if method
        return method, args
      end
    end

    def run(val)
      method, args = parse(val)
      if method
        send(method, args)
      end
    end

    def run_test(*args)
      $stdout.puts "running test #{args}"
      @runner.run_test(args)
    end

    def hostname(name)
      Srunr.configuration.hostname = name
    end

    def before_suite(*args)
      @runner.before_suite
    end

    def after_suite(*args)
      @runner.after_suite
    end
  end

  class Cli

    def initialize
      @rd_pipe, @wr_pipe = IO.pipe
      @parser = CommandParser.new
    end

    def start
      trap_int
      loop do
        ready = IO.select([@rd_pipe, $stdin]).first.first
        if ready == $stdin
          command = $stdin.gets.chomp
          if !command.empty?
            @parser.run(command)
          end
        elsif ready == @rd_pipe
          if @rd_pipe.gets.chomp == "INT"
            abort("Caught INT signal")
          end
        end
      end
    end

    def trap_int
      Signal.trap("INT") do
        $stdout.print("\r")
        @wr_pipe.puts "INT"
      end
    end

  end
end
