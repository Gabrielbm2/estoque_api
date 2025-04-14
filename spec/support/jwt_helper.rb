module JwtHelper
  def token_for_user(user)
    JsonWebToken.encode(user_id: user.id)
  end
end

RSpec.configure do |config|
  config.include JwtHelper
end