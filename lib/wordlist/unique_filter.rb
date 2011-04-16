require 'set'
require 'digest/md5'

module Wordlist
  class UniqueFilter

    #
    # Creates a new UniqueFilter object.
    #
    def initialize
      @checksums = Set[]
    end

    #
    # Determines if the given word has been previously seen.
    #
    # @param [String] word
    #   The word to check for.
    #
    # @return [Boolean]
    #   Specifies whether the word has been previously seen.
    #
    def include?(word)
      @checksums.include?(Digest::MD5.hexdigest(word))
    end

    #
    # Marks the given word as previously seen.
    #
    # @param [String] word
    #   The word to mark as previously seen.
    #
    # @return [Boolean]
    #   Specifies whether or not the word has not been previously seen
    #   until now.
    #
    def <<(word)
      md5 = Digest::MD5.hexdigest(word)

      return false if @checksums.include?(md5)

      @checksums << md5
      return true
    end

    #
    # Passes the given word through the unique filter.
    #
    # @param [String] word
    #   The word to pass through the unique filter.
    #
    # @yield [word]
    #   The given block will be passed the word, if the word has not been
    #   previously seen by the filter.
    #
    # @yieldparam [String] word
    #   A unique word that has not been previously seen by the filter.
    #
    # @return [nil]
    #
    def filter(word)
      if self << word
        yield word
      end
    end

    #
    # Clears the unique filter.
    #
    # @return [UniqueFilter]
    #   The cleared filter.
    #
    def clear
      @checksums.clear
      return self
    end

  end
end
