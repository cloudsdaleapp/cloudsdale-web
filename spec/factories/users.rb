FactoryGirl.define do

  factory :user do

    sequence(:name) do |n|
      mock_name = "AAA"
      n.times { mock_name.succ! }
      mock_name
    end

    sequence(:email)          { |n| "pony-#{n}@cloudsdale.org" }
    email_verified_at         nil
    skype_name                "myskype.name"
    auth_token                { SecureRandom.hex(16) }
    role                      0
    member_since              { 1.year.ago }
    invisible                 false
    force_password_change     false
    force_name_change         false
    tnc_last_accepted         { 10.days.ago }
    confirmed_registration_at { 10.days.ago }
    preferred_status          :online
    last_seen_at              { 2.hours.ago }

    factory :suspended_user do
      suspended_until         { 10.days.from_now }
      reason_for_suspension   "Fails at life"
    end

  end

end
