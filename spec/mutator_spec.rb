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

  it "should compensate for drift when replacing text" do
    mutator = Mutator.new('o', '00')
    expected = %w[lolo l00lo lol00 l00l00]

    mutator.each('lolo').to_a.should == expected
  end

  it "should iterate over every possible substitution" do
    mutator = Mutator.new(/o/,'0')
    expected = %w[lolol l0lol lol0l l0l0l]

    mutator.each('lolol').to_a.should == expected
  end

  it "should iterate over the original word, if no matches were found" do
    word = 'hello'
    mutator = Mutator.new('x','0')

    mutator.each('hello').to_a.should == [word]
  end
end
