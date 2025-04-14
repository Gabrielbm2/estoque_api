module AuthHelpers
  def self.included(base)
    base.class_eval do
      let(:Authorization) { nil } unless method_defined?(:Authorization)
    end
  end
end

RSpec.configure do |config|
  config.include AuthHelpers
end