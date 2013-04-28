require 'spec_helper'

describe DispatchPolicy do
  subject { DispatchPolicy }
  let(:dispatch) { build(:dispatch) }
  let(:user)     { build(:user) }

  permissions :create?, :update?, :index?, :show?, :destroy? do

    [:admin,:developer,:founder].each do |role|
      it "does permit a user of role :#{role}" do
        user.role = User::ROLES[role]
        should permit(user,dispatch)
      end
    end
    [:normal,:donor,:legacy,:associate,:verified].each do |role|
      it "does not permit a user of role :#{role}" do
        user.role = User::ROLES[role]
        should_not permit(user,dispatch)
      end
    end
  end

  permissions :destroy? do
    it "does not permit any user to destroy a dispatch" do
      should_not permit(user,dispatch)
    end
  end

end
