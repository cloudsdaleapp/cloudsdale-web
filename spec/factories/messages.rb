FactoryGirl.define do

  factory :message do

    client_id { SecureRandom.hex(4) }
    content   "Hello World!"
    device    "desktop"
    timestamp { Time.now }

    association :author, factory: :user


  end

end
