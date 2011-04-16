require 'wordlist/unique_filter'
require 'wordlist/mutator'

module Wordlist
  class List

    include Enumerable

    # Maximum length of words
    attr_accessor :max_length

    # Minimum length of words
    attr_accessor :min_length

    #
    # Creates a new List object.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [Integer] :max_length
    #   The maximum length of words produced by the list.
    #
    # @option options [Integer] :min_length
    #   The minimum length of words produced by the list.
    #
    # @yield [list]
    #   If a block is given, it will be passed the new list object.
    #
    # @yieldparam [List] list
    #   The new list object.
    #
    def initialize(options={})
      @mutators = []

      @max_length = nil
      @min_length = 0

      if options[:max_length]
        @max_length = options[:max_length]
      end

      if options[:min_length]
        @min_length = options[:min_length]
      end

      yield self if block_given?
    end

    #
    # Adds a mutation rule for the specified pattern, to be replaced
    # using the specified substitute.
    #
    # @param [String, Regexp] pattern
    #   The pattern to recognize text to mutate.
    #
    # @param [String, Integer, nil] substitute
    #   The optional text to replace recognized text.
    #
    # @yield [match]
    #   If a block is given, it will be passed the recognized text to be
    #   mutated. The return value of the block will be used to replace
    #   the recognized text.
    #
    # @yieldparam [String] match
    #   The recognized text to be mutated.
    #
    # @example
    #   list.mutate 'o', '0'
    #   
    #   list.mutate '0', 0x41
    #   
    #   list.mutate(/[oO]/) do |match|
    #     match.swapcase
    #   end
    #
    def mutate(pattern,substitute=nil,&block)
      @mutators << Mutator.new(pattern,substitute,&block)
    end

    #
    # Enumerate through every word in the list.
    #
    # @yield [word]
    #   The given block will be passed each word in the list.
    #
    # @yieldparam [String] word
    #   A word from the list.
    #
    # @example
    #   list.each_word do |word|
    #     puts word
    #   end
    #
    def each_word(&block)
    end

    #
    # Enumerates through every unique word in the list.
    #
    # @yield [word]
    #   The given block will be passed each unique word in the list.
    #
    # @yieldparam [String] word
    #   A unique word from the list.
    #
    # @example
    #   list.each_unique do |word|
    #     puts word
    #   end
    #
    def each_unique
      unique_filter = UniqueFilter.new()

      each_word do |word|
        if unique_filter.saw!(word)
          yield word
        end
      end

      unique_filter = nil
    end

    #
    # Enumerates through every unique mutation, of every unique word, using
    # the mutator rules define for the list.
    #
    # @yield [word]
    #   The given block will be passed every mutation of every unique
    #   word in the list.
    #
    # @yieldparam [String] word
    #   A mutation of a unique word from the list.
    #
    # @example
    #   list.each_mutation do |word|
    #     puts word
    #   end
    #
    def each_mutation(&block)
      mutation_filter = UniqueFilter.new()

      mutator_stack = [lambda { |mutated_word|
        # skip words shorter than the minimum length
        next if mutated_word.length < @min_length

        # truncate words longer than the maximum length
        mutated_word = mutated_word[0,@max_length] if @max_length

        if mutation_filter.saw!(mutated_word)
          yield mutated_word
        end
      }]

      (@mutators.length-1).downto(0) do |index|
        mutator_stack.unshift(lambda { |word|
          prev_mutator = @mutators[index]
          next_mutator = mutator_stack[index+1]

          prev_mutator.each(word,&next_mutator)
        })
      end

      each_unique(&(mutator_stack.first))
    end

    alias each each_mutation

  end
end
