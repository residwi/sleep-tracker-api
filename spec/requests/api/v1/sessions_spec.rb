require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/v1/sign_in" do
    context "with valid credentials" do
      it "signs in the user" do
        post api_v1_sign_in_path, params: { email: user.email, password: "secret_password" }
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid credentials" do
      it "does not sign in the user" do
        post api_v1_sign_in_path, params: { email: user.email, password: "wrong_password" }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["message"]).to eq("That email or password is incorrect")
      end
    end
  end

  describe "DELETE /api/v1/sessions/:id" do
    it "signs out the user" do
      token = api_sign_in_as(user)

      delete api_v1_session_path(user.sessions.last), headers: { Authorization: "Bearer #{token}" }
      expect(response).to have_http_status(:no_content)
    end
  end
end
