FactoryBot.define do
  factory :file_image do
    filename { 'test.pdf' }
    content_type { 'application/pdf' }
    key { "Uploads/#{SecureRandom.uuid}/test.pdf" }
    byte_size { 1024 }
    bucket { 'my-bucket' }
  end

  factory :file_image_in_use, parent: :file_image do
    filename { 'test-used.pdf' }
    key { "Uploads/#{SecureRandom.uuid}/test-used.pdf" }
    after(:create) do |file_image|
      create(:product, file_image: file_image)
    end
  end
end
