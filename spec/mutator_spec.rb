require 'wordlist/mutator'

require 'spec_helper'

describe Mutator do
  it "should replace matched text with a byte" do
    mutator = Mutator.new('o',0x41)
    mutator.replace('o').should == 'A'
  end

  it "should replace matched text with a String" do
    mutator = Mutator.new('o','0')
    mutator.replace('o').should == '0'
  end

  it "should replace matched text using a proc" do
    mutator = Mutator.new('o') { |match| match * 2 }
    mutator.replace('o').should == 'oo'
  end

  it "should iterate over every possible substitution" do
    expected = ['lolol', 'l0lol', 'lol0l', 'l0l0l']
    mutations = []

    mutator = Mutator.new(/o/,'0')
    mutator.each('lolol') do |mutation|
      mutations << mutation
    end

    mutations.should == expected
  end

  it "should iterate over the original word, if no matches were found" do
    mutations = []
    mutator = Mutator.new('x','0')

    mutator.each('hello') do |mutant|
      mutations << mutant
    end

    mutations.should == ['hello']
  end
end
