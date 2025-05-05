module Helpers
  module Authentication
    module Request
      def api_sign_in_as(user)
        post(sign_in_url, params: { email: user.email, password: "secret_password" })

        response.headers["X-Session-Token"]
      end
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::Authentication::Request, type: :request
  config.include ActiveSupport::Testing::TimeHelpers
end
