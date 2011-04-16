require 'wordlist/unique_filter'
require 'wordlist/parsers'

module Wordlist
  class Builder

    include Parsers

    # Path of the word-list
    attr_reader :path

    # Minimum number of words
    attr_reader :min_words

    # Maximum number of words
    attr_reader :max_words

    # File for the word-list
    attr_reader :file

    # The unique word filter
    attr_reader :filter

    # The queue of words awaiting processing
    attr_reader :word_queue

    #
    # Creates a new word-list Builder object.
    #
    # @param [String] path
    #   The path of the word-list file.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [Integer] :min_words (1)
    #   The minimum number of words each line of the word-list must contain.
    #
    # @option options [Integer] :max_words
    #   The maximum number of words each line of the word-list may contain.
    #   Defaults to the value of `:min_words`, if not given.
    #
    def initialize(path,options={})
      super()

      @path = File.expand_path(path)

      @min_words = (options[:min_words] || 1)
      @max_words = (options[:max_words] || @min_words)

      @file = nil
      @filter = UniqueFilter.new
      @word_queue = []

      yield self if block_given?
    end

    #
    # Creates a new Builder object with the given arguments, opens the
    # word-list file, passes the builder object to the given block
    # then finally closes the word-list file.
    #
    # @param [Array] arguments
    #   Additional arguments to pass to {Builder.new}.
    #
    # @yield [builder]
    #   If a block is given, it will be passed the new builder.
    #
    # @yieldparam [Builder] builder
    #   The newly created builer object.
    #
    # @return [Builder]
    #   The newly created builder object.
    #
    # @example
    #   Builder.build('some/path') do |builder|
    #     builder.parse(readline)
    #   end
    #
    def self.build(*arguments,&block)
      self.new(*arguments) do |builder|
        builder.open!
        builder.build!(&block)
        builder.close!
      end
    end

    #
    # Opens the word-list file for writing. If the file already exists, the
    # previous words will be used to filter future duplicate words.
    #
    # @return [File]
    #   The open word-list file.
    #
    def open!
      if File.file?(@path)
        File.open(@path) do |file|
          file.each_line do |line|
            @filter << line.chomp
          end
        end
      end

      @file = File.new(@path,File::RDWR | File::CREAT | File::APPEND)
    end

    #
    # Default to be called when the word-list is to be built.
    #
    # @yield [builder]
    #   If a block is given, it will be passed the new builder object.
    #
    def build!
      yield self if block_given?
    end

    #
    # Enqueues a given word for processing.
    #
    # @param [String] word
    #   The word to enqueue.
    #
    # @return [String]
    #   The enqueued word.
    #
    def enqueue(word)
      # enqueue the word
      if @max_words == 1
        @word_queue[0] = word.to_s
      else
        @word_queue << word.to_s

        # make sure the queue does not overflow
        if @word_queue.length > @max_words
          @word_queue.shift
        end
      end

      return word
    end

    #
    # Enumerates over the combinations of previously seen words.
    #
    # @yield [combination]
    #   The given block will be passed the combinations of previously
    #   seen words.
    #
    # @yieldparam [String] combination
    #   A combination of one or more space-separated words.
    #
    def word_combinations
      if @max_words == 1
        yield @word_queue[0]
      else
        current_words = @word_queue.length

        # we must have atleast the minimum amount of words
        if current_words >= @min_words
          upper_bound = (current_words - @min_words)

          # combine the words
          upper_bound.downto(0) do |i|
            yield @word_queue[i..-1].join(' ')
          end
        end
      end
    end

    #
    # Appends the given word to the word-list file, only if it has not
    # been previously seen.
    #
    # @param [String] word
    #   The word to append.
    #
    # @return [Builder]
    #   The builder object.
    #
    def <<(word)
      enqueue(word)

      if @file
        word_combinations do |words|
          if @filter.filter(words)
            @file.puts(words)
          end
        end
      end

      return self
    end

    #
    # Add the given words to the word-list.
    #
    # @param [Array<String>] words
    #   The words to add to the list.
    #
    # @return [Builder]
    #   The builder object.
    #
    def +(words)
      words.each { |word| self << word }
      return self
    end

    #
    # Parses the given text, adding each unique word to the word-list file.
    #
    # @param [String] text
    #   The text to parse.
    #
    def parse(text)
      super(text).each { |word| self << word }
    end

    #
    # Parses the contents of the file at the given path, adding each unique
    # word to the word-list file.
    #
    # @param [String] path
    #   The path of the file to parse.
    #
    def parse_file(path)
      File.open(path) do |file|
        file.each_line do |line|
          parse(line)
        end
      end
    end

    #
    # Closes the word-list file.
    #
    def close!
      if @file
        @file.close
        @file = nil

        @filter.clear
        @word_queue.clear
      end
    end

  end
end
