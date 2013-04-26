require 'spec_helper'

describe Dispatch do

  subject { create(:dispatch) }
  it { subject.class.should be Dispatch }

  describe '#status' do

    it 'returns :draft when not published' do
      subject.status.should be :draft
    end

    it 'returns :sent when published' do
      subject.stub(:published_at).and_return(10.days.ago)
      subject.status.should be :sent
    end

  end

  describe '#formatted_body' do
    it 'calls Markdown with HTML' do
      Redcarpet::Markdown.any_instance.should_receive(:render).and_return("")
      subject.formatted_body
    end
  end

  describe '#unformatted_body' do
    it 'calls Markdown with StripDown' do
      Redcarpet::Markdown.any_instance.should_receive(:render).and_return("")
      subject.unformatted_body
    end
  end

end
