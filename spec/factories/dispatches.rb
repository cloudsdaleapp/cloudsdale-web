# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :dispatch do

    subject "Hello World"
    body "**Markdown Body**"
    published_at nil

    factory :published_dispatch do
      published_at { 10.days.ago }
    end

  end

end
