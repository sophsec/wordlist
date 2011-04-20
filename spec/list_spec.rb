require 'spec_helper'
require 'wordlist/list'

describe List do
  before(:all) do
    @source = described_class.new do |list|
      list.yield 'omg.hackers'
    end

    @source.mutate 'o', '0'
    @source.mutate 'a', 'A'
    @source.mutate 'e', '3'
    @source.mutate 's', '5'
  end

  it "should iterate over each word" do
    words = []

    @source.each_word { |word| words << word }

    words.should == ['omg.hackers']
  end

  it "should iterate over each unique word" do
    words = []

    @source.each_unique { |word| words << word }

    words.should == ['omg.hackers']
  end

  it "should iterate over every possible mutated word" do
    mutations = %w{
      0mg.hAck3r5
      0mg.hAck3rs
      0mg.hAcker5
      0mg.hAckers
      0mg.hack3r5
      0mg.hack3rs
      0mg.hacker5
      0mg.hackers
      omg.hAck3r5
      omg.hAck3rs
      omg.hAcker5
      omg.hAckers
      omg.hack3r5
      omg.hack3rs
      omg.hacker5
      omg.hackers
    }

    @source.each_mutation do |mutation|
      mutations.include?(mutation).should == true
      mutations.delete(mutation)
    end

    mutations.should == []
  end
end
