require 'combinatorics/list_comprehension'

module Wordlist
  class Mutator

    include Enumerable

    # The pattern to match
    attr_accessor :pattern

    # The data to substitute matched text with
    attr_accessor :substitute

    #
    # Creates a new Mutator object.
    #
    # @param [String, Regexp] pattern
    #   The pattern which recognizes text to mutate.
    #
    # @param [String, Integer] substitute
    #   The optional text to replace recognized text.
    #
    # @yield [match]
    #   If a block is given, it will be used to mutate recognized text.
    #
    # @yieldparam [String] match
    #   The match text to mutate.
    #
    def initialize(pattern,substitute=nil,&block)
      @pattern = pattern
      @substitute = (substitute || block)
    end

    #
    # Mutates the given text.
    #
    # @param [String] matched
    #   The recognized text to be mutated.
    #
    # @return [String]
    #   The mutated text.
    #
    def mutate(matched)
      result = if @substitute.kind_of?(Proc)
                 @substitute.call(matched)
               else
                 @substitute
               end

      result = if result.kind_of?(Integer)
                 result.chr
               else
                 result.to_s
               end

      return result
    end

    #
    # Enumerates over every possible mutation of the given word.
    #
    # @param [String] word
    #   The word to mutate.
    #
    # @yield [mutation]
    #   The given block will be passed every possible mutation of the
    #   given word.
    #
    # @yieldparam [String] mutation
    #   One possible mutation of the given word.
    #
    # @return [String]
    #   The original word.
    #
    def each(word)
      explode(word).comprehension do |fragments|
        yield fragments.join
      end
    end

    def explode(word)
      match = word.match(@pattern)

      fragments = []
      prev = 0

      match.length.times do |n|
        start, stop = match.offset(n)

        if start > prev
          fragments << word[prev, (start-prev)]
        end

        fragment = word[start, (stop-start)]
        fragments << [fragment, mutate(fragment)]
        prev = stop
      end

      if stop < word.length
        fragments << word[stop,-1]
      end

      return fragments
    end

    #
    # Inspects the mutator.
    #
    # @return [String]
    #   The inspected mutator.
    #
    def inspect
      "#{@pattern.inspect} -> #{@substitute.inspect}"
    end

  end
end
