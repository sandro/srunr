module Srunr
  class Loader

    attr_reader :all_specs

    def initialize
      @all_specs = {}
    end

    def load_all(out=$stdout, err=$stderr)
      load_application unless application_loaded?
      load_specs(out, err) unless specs_loaded?
    end

    def load_application
      ENV["RAILS_ENV"] ||= 'test'
      bundle_install
      require File.expand_path("config/application", Dir.pwd)
      @application_loaded = true
      $stderr.puts "done loading application"
    end

    def load_specs(out, err)
      require "rspec/core"
      ::RSpec::Core::Runner.disable_autorun!
      config_options = ::RSpec::Core::ConfigurationOptions.new(["spec"])
      config_options.parse_options
      ::RSpec.configuration.error_stream = err
      ::RSpec.configuration.output_stream = out
      config_options.configure ::RSpec.configuration
      ::RSpec.configuration.load_spec_files
      file_names_with_location
      @specs_loaded = true
      $stderr.puts "done loading specs"
    end

    def application_loaded?
      @application_loaded
    end

    def specs_loaded?
      @specs_loaded
    end

    def bundle_install
      system("bundle check") || system("bundle install --local")
    end

    def file_names_with_location
      executables = gather_groups(::RSpec.world.example_groups)
      locations = executables.map do |e|
        if e.respond_to?(:examples)
          e.metadata[:example_group][:location]
        else
          if e.example_group.metadata[:shared_group_name]
            e.metadata[:example_group][:location]
          else
            e.metadata[:location]
          end
        end
      end
      locations.map.with_index do |location, i|
        @all_specs[location] ||= []
        executable = executables[i]
        @all_specs[location] << executable
      end
      locations
    end

    # recursively gather groups containing a before(:all) hook, and examples
    def gather_groups(groups)
      groups.map do |g|
        before_all_hooks = g.send(:find_hook, :before, :all, nil, nil)
        if g.metadata.has_key?(:shared_group_name)
          g
        elsif before_all_hooks.any?
          g
        else
          (g.filtered_examples || []) + gather_groups(g.children)
        end
      end.compact.flatten
    end

  end
end
