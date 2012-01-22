require 'spec_helper'

describe Drop do
  describe "#initialize" do
    it 'should include put source and raw source if url is supplied' do
      drop = Drop.new(url: 'http://www.google.com')
      drop.source.should_not be_nil
      drop.source.should be_a_kind_of(String)
      drop.raw_source.should_not be_nil
      drop.raw_source.should be_a_kind_of(String)
    end
  end
end
