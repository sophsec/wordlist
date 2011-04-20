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
    # @param [String, Integer, #call] substitute
    #   The optional text to replace recognized text.
    #
    # @yield [match]
    #   If a block is given, it will be used to mutate recognized text.
    #
    # @yieldparam [String] match
    #   The match text to mutate.
    #
    def initialize(pattern,substitute=nil,&block)
      @pattern = unless pattern.kind_of?(Regexp)
                   Regexp.compile(Regexp.escape(pattern))
                 else
                   pattern
                 end

      @substitute = (substitute || block)
    end

    #
    # Finds the indexes and lengths of all matched sub-strings.
    #
    # @param [String] word
    #   The word to search for matches within.
    #
    # @return [Array<Array<index, length>>]
    #   The Array of indexes and lengths.
    #
    # @since 0.2.0
    #
    def matches(word)
      word = word.dup
      matches = []
      offset = 0

      while (match = word.match(@pattern))
        i,j = match.offset(0)
        matches << [offset+i, j-i]

        word = word.slice!(j..-1)
        offset += j
      end

      return matches
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
      result = if @substitute.respond_to?(:call)
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
    # @return [Enumerator]
    #   If no block is given, an `Enumerator` object will be returned.
    #
    def each(word)
      return enum_for(:each,word) unless block_given?

      matches = matches(word)

      (matches.length + 1).times do |i|
        matches.combination(i) do |indexes|
          mutant = word.dup
          drift = 0

          indexes.each do |index,length|
            match = mutant[index,length]
            replacement = replace(match)

            mutant[index + drift, length] = replacement
            drift += (replacement.length - match.length)
          end

          yield mutant
        end
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
