require 'wordlist/list'

module Wordlist
  module Formats
    class FlatFile < List

      def initialize(path,options={})
        @path = path

        super(options)
      end

      def each_word(&block)
        File.open(@path) do |file|
          file.each_line do |line|
            yield line.chomp
          end
        end
      end

    end
  end
end