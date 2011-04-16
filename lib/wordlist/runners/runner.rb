require 'optparse'

module Wordlist
  module Runners
    class Runner
      #
      # Creates and runs the runner with the given arguments.
      #
      # @param [Array<String>] args
      #   Arguments to parse.
      #
      def self.run(*args)
        runner = self.new
        runner.run(*args)
      end

      #
      # Runs the runner with the given arguments.
      #
      # @param [Array<String>] args
      #   Arguments to run the runner with.
      #
      def run(*args)
        optparse(*args)
      end

      protected

      #
      # Prints the given error message.
      #
      # @param [String] message
      #   The error message to print.
      #
      def print_error(message)
        $stderr.puts "#{$0}: #{message}"
      end

      #
      # Parses the given arguments.
      #
      # @param [Array<String>] args
      #   Arguments to parse.
      #
      # @yield [opts]
      #   If a block is given, it will be passed the option parse to be
      #   configured.
      #
      # @yieldparam [OptionParser] opts
      #   The option parser to be configured.
      #
      def optparse(*args)
        opts = OptionParser.new
        yield opts if block_given?

        begin
          opts.parse!(args)
        rescue OptionParser::InvalidOption => e
          $stderr.puts e.message
          $stderr.puts opts
          exit -1
        end
      end
    end
  end
end
