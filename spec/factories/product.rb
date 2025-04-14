FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 1..1000.0) }
    quantity { Faker::Number.between(from: 1, to: 100) }

    association :user
    association :file_image

    trait :out_of_stock do
      quantity { 0 }
    end

    trait :with_image do
      after(:build) do |product|
        file_path = Rails.root.join('spec', 'fixtures', 'files', 'product.jpg')
        product.image.attach(
          io: File.open(file_path),
          filename: 'product.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    factory :product_with_image, traits: [:with_image]
    factory :out_of_stock_product, traits: [:out_of_stock]
  end
end
