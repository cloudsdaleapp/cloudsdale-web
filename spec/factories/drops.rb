# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  
  factory :drop do
    url "http://test.cloudsdale.org:3300/path?q=query"
  end
  
  factory :image_drop do
    url "http://test.cloudsdale.org:3300/image.png"
  end
  
end