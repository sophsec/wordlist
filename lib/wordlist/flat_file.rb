require 'wordlist/list'

module Wordlist
  class FlatFile < List

    # The path to the flat-file
    attr_accessor :path

    #
    # Opens a new FlatFile list.
    #
    # @param [String] path
    #   The path to the flat file word-list read from.
    #
    # @param [Hash] options
    #   Additional options.
    #
    def initialize(path,options={})
      @path = path

      super(options) do |list|
        File.open(@path) do |file|
          file.each_line do |line|
            list.yield line.chomp
          end
        end
      end
    end

  end
end
