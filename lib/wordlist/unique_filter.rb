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
    # @return [UniqueFilter]
    #   The unqiue filter.
    #
    def <<(word)
      @checksums << Digest::MD5.hexdigest(word)
      return self
    end

    #
    # Passes the given word through the unique filter.
    #
    # @param [String] word
    #   The word to pass through the unique filter.
    #
    # @return [Boolean]
    #   Specifies whether the word was unique, or previously seen.
    #
    def filter(word)
      md5 = Digest::MD5.hexdigest(word)
      new_word = !@checksums.include?(md5)

      @checksums << md5
      return new_word
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
