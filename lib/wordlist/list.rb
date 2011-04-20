require 'wordlist/unique_filter'
require 'wordlist/mutator'

if RUBY_VERSION < '1.9.'
  require 'generator'
end

module Wordlist
  class List

    include Enumerable

    Generator = if RUBY_VERSION < '1.9.'
                  ::Generator
                else
                  Enumerator::Generator
                end

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
    # @option options [Hash{String,Regexp => Integer,String,#call}] :mutations
    #   The mutation rules for the list.
    #
    # @option options [#each] :words
    #   The words for the list.
    #
    # @yield [generator]
    #   The given block will be passed a generator to populate with words.
    #
    # @yieldparam [Generator] generator
    #   The generator to populate with words.
    #
    # @raise [ArgumentError]
    #   The `:words` option or a block must be specified.
    #
    def initialize(options={},&block)
      @mutators = []

      @max_length = nil
      @min_length = 0

      if options[:max_length]
        @max_length = options[:max_length]
      end

      if options[:min_length]
        @min_length = options[:min_length]
      end

      if options[:mutations]
        options[:mutations].each do |pattern,substitute|
          mutate(pattern,substitute)
        end
      end

      @words = if block
                 Generator.new(&block)
               elsif options.has_key?(:words)
                 options[:words]
               else
                 raise(ArgumentError,"must specify :words or a block")
               end
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
      @words.each(&block)
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
        if unique_filter.filter(word)
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
      unique = UniqueFilter.new()

      each_word do |word|
        if unique.filter(word)
          yield word

          # batch of mutated words
          mutants = [word]

          @mutators.each do |mutator|
            # next batch of mutated words
            new_mutants = []

            mutants.each do |mutant|
              mutator.each(mutant) do |new_mutant|
                # only add the new mutant, if its new
                if unique.filter(new_mutant)
                  new_mutants << new_mutant
                end
              end
            end

            new_mutants.each(&block)
            mutants += new_mutants
          end
        end
      end
    end

    alias each each_mutation

  end
end
