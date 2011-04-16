# Wordlist

* [wordlist.rubyforge.org](http://wordlist.rubyforge.org/)
* [github.com/sophsec/wordlist](http://github.com/sophsec/wordlist/)
* Postmodern (postmodern.mod3 at gmail.com)

## Description

A Ruby library for generating and working with word-lists. Wordlist allows
one to efficiently generate unique word-lists from arbitrary text or
other sources, such as website content. Wordlist can also quickly enumerate
through words within an existing word-list, applying multiple mutation
rules to each word in the list.

## Features

* Uses a bucket system of CRC32 hashes for efficient filtering of duplicate
  words.
* Can build wordlists containing multi-word phrases.
* Can build wordlists containing phrases containing a minimum and maximum
  number of words.
* Supports adding mutation rules to a word-list, which are applied to
  words as the list is enumerated.
* Supports building word-lists from arbitrary text.
* Supports custom word-list builders:
  * Wordlist::Builders::Website: Build word-lists from website content.
* Supports custom word-list formats:
  * Wordlist::FlatFile: Enumerates through the words in a flat-file
    word-list.

## Examples

Build a word-list from arbitrary text:

    Wordlist::Builder.build('list.txt') do |builder|
      builder.parse(some_text)
    end

Build a word-list from another file:

    Wordlist::Builder.build('list.txt') do |builder|
      builder.parse_file('some/file.txt')
    end

Build a word-list of phrases containing at most three words, from the
arbitrary text:

    Wordlist::Builder.build('list.txt', :max_words => 3) do |builder|
      builder.parse(some_text)
    end

Build a word-list from content off a website:

    require 'wordlist/builders/website'

    Wordlist::Builders::Website.build(
      'list.txt',
      :host => 'www.example.com'
    )

Enumerate through each word in a flat-file word-list:

    list = Wordlist::FlatFile.new('list.txt')
    list.each_word do |word|
      puts word
    end

Enumerate through each unique word in a flat-file word-list:

    list.each_unique do |word|
      puts word
    end

Define mutation rules, and enumerate through each unique mutation of each
unique word in the word-list:

    list.mutate 'o', '0'
    list.mutate '@', 0x41
    list.mutate(/[hax]/i) { |match| match.swapcase }

    list.each_mutation do |word|
      puts word
    end

## Requirements

* [Ruby](http://www.ruby-lang.org) >= 1.8.7
* [spidr](http://spidr.rubyforge.org) >= 0.1.9

## Install

    $ sudo gem install wordlist

## License

See {file:LICENSE.txt} for license information.

