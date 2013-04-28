require 'spec_helper'

describe MessagePolicy do

  subject { MessagePolicy }
  let(:message) { build(:message) }
  let(:user)     { build(:user) }

  permissions :create?, :update? do

    before :each do
      subject.any_instance.stub(:user_is_not_banned_from_topic?).and_return(true)
      subject.any_instance.stub(:user_is_member_of_topic?).and_return(true)
      subject.any_instance.stub(:topic_is_unlocked?).and_return(true)
      user.stub(:is_of_role?).with(any_args).and_return(false)
    end

    it 'succeeds' do
      should permit(user,message)
    end

    it 'succeeds, if user is admin' do
      subject.any_instance.stub(:user_is_not_banned_from_topic?).and_return(false)
      subject.any_instance.stub(:user_is_member_of_topic?).and_return(false)
      subject.any_instance.stub(:topic_is_unlocked?).and_return(false)
      user.stub(:is_of_role?).with(any_args).and_return(true)
      should permit(user,message)
    end

    it 'fails if user is banned' do
      subject.any_instance.stub(:user_is_not_banned_from_topic?).and_return(false)
      should_not permit(user,message)
    end

    it 'fails topic is locked' do
      subject.any_instance.stub(:user_is_member_of_topic?).and_return(false)
      should_not permit(user,message)
    end

    it 'fails user is not member' do
      subject.any_instance.stub(:topic_is_unlocked?).and_return(false)
      should_not permit(user,message)
    end

  end

  describe '#user_is_member_of_topic?' do

    it 'succeeds if the chats topic includes the user id' do
      message.stub_chain(:chat,:topic,:user_ids).and_return [user.id]
      subject.new(user,message).send(:user_is_member_of_topic?).should be_true
    end

    it 'fails if the chat topic does not include the user id' do
      message.stub_chain(:chat,:topic,:user_ids).and_return []
      subject.new(user,message).send(:user_is_member_of_topic?).should be_false
    end

  end

  describe '#topic_is_unlocked?' do

    it 'succeeds if the chats topic is not locked' do
      message.stub_chain(:chat,:topic,:locked?).and_return false
      subject.new(user,message).send(:topic_is_unlocked?).should be_true
    end

    it 'fails if the chat topic is locked' do
      message.stub_chain(:chat,:topic,:locked?).and_return true
      subject.new(user,message).send(:topic_is_unlocked?).should be_false
    end

  end

  describe '#user_is_not_banned_from_topic?' do

    it 'succeeds if the user is not banned from the chat topic' do
      message.stub_chain(:chat,:topic,:has_banned?).and_return false
      subject.new(user,message).send(:user_is_not_banned_from_topic?).should be_true
    end

    it 'fails if the user is banned from the chat topic' do
      message.stub_chain(:chat,:topic,:has_banned?).and_return true
      subject.new(user,message).send(:user_is_not_banned_from_topic?).should be_false
    end

  end

end
