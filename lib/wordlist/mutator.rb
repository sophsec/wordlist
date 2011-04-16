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
    # Replaces the given text.
    #
    # @param [String] matched
    #   The recognized text to be replaced.
    #
    # @return [String]
    #   The replacement text.
    #
    def replace(matched)
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
    # Explodes a word into an Array of possible substitutions.
    #
    # @param [String] word
    #   The word to explode.
    #
    # @return [Array<Array, String>]
    #   The Array of possible substitutions.
    #
    # @since 0.2.0
    #
    def explode(word)
      fragments = []
      prev = 0

      word.scan(@pattern) do |match|
        index = word.index(match,prev)
        length = match.length

        if index > prev
          fragments << word[prev, (index-prev)]
        end

        fragment = word[index, length]
        fragments << [fragment, replace(fragment)]
        prev = index + length
      end

      if prev < word.length
        fragments << word[prev..-1]
      end

      return fragments
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
