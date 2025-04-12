FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    role { 'user' }

    trait :admin do
      role { 'admin' }
    end
    
    trait :with_avatar do
      after(:build) do |user|
        file_path = Rails.root.join('spec', 'fixtures', 'files', 'avatar.jpg')
        user.avatar.attach(
          io: File.open(file_path),
          filename: 'avatar.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
    
    factory :admin, traits: [:admin]
    factory :user_with_avatar, traits: [:with_avatar]
  end
end