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
      @pattern = unless pattern.kind_of?(Regexp)
                   Regexp.compile(Regexp.escape(pattern))
                 else
                   pattern
                 end

      @substitute = (substitute || block)
    end

    def matches(word)
      matches = []
      index = 0

      while (match = word.match(@pattern,index))
        i,j = match.offset(0)

        matches << [i, j-i]
        index = j
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
