require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /sign_in" do
    context "with valid credentials" do
      it "signs in the user and redirects to root" do
        post sign_in_path, params: { email: user.email, password: "secret_password" }
        expect(response).to have_http_status(:created)

        get root_path, headers: { Authorization: "Bearer #{response.headers["X-Session-Token"]}" }
        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid credentials" do
      it "does not sign in the user" do
        post sign_in_path, params: { email: user.email, password: "wrong_password" }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["message"]).to eq("That email or password is incorrect")
      end
    end
  end

  describe "DELETE /session/:id" do
    it "signs out the user" do
      token = api_sign_in_as(user)

      delete session_path(user.sessions.last), headers: { Authorization: "Bearer #{token}" }
      expect(response).to have_http_status(:no_content)
    end
  end
end
