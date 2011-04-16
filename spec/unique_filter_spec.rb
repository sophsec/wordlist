require 'wordlist/unique_filter'

require 'spec_helper'

describe UniqueFilter do
  before(:each) do
    @filter = UniqueFilter.new
  end

  it "should recognize previously added words" do
    @filter << 'cat'

    @filter.should include('cat')
    @filter.should_not include('dog')
  end

  it "should only add a unique word once" do
    (@filter << 'cat').should == true
    (@filter << 'cat').should == false
  end

  it "should only pass unique words through the filter" do
    input = ['dog', 'cat', 'dog']
    output = []

    input.each do |word|
      @filter.filter(word) do |result|
        output << result
      end
    end

    output.should == ['dog', 'cat']
  end
end
