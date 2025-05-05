require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /index" do
    context "when not signed in" do
      it "returns a 401 status" do
        get root_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when signed in" do
      it "returns a 200 status" do
        user = create(:user)
        token = api_sign_in_as(user)

        get root_path, headers: { Authorization: "Bearer #{token}" }
        expect(response).to be_successful
      end
    end
  end
end
