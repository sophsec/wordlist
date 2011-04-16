require 'set'
require 'digest/md5'

module Wordlist
  class UniqueFilter

    # CRC32 Hashes of words seen so far
    attr_reader :seen

    #
    # Creates a new UniqueFilter object.
    #
    def initialize
      @seen = Set[]
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
    def seen?(word)
      @seen.include?(Digest::MD5.hexdigest(word))
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
    def saw!(word)
      md5 = Digest::MD5.hexdigest(word)

      return false if @seen.include?(md5)

      @seen << md5
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
    def pass(word)
      yield word if saw!(word)
      return nil
    end

    #
    # Clears the unique filter.
    #
    # @return [UniqueFilter]
    #   The cleared filter.
    #
    def clear
      @seen.clear
      return self
    end

  end
end
