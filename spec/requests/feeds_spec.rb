require "rails_helper"

RSpec.describe "Feeds", type: :request do
  describe "GET /feeds" do
    let(:user) { create(:user) }
    let(:other_users) { create_list(:user, 3) }

    before do
      other_users.each do |other_user|
        user.follow(other_user)
      end

      token = api_sign_in_as(user)
      @authentication_header = { Authorization: "Bearer #{token}" }
    end

    it "returns the feeds of the current user and their following" do
      sleep_records = create_list(:sleep_record, 2, user: user)
      other_sleep_records = other_users.map do |other_user|
        create_list(:sleep_record, 2, user: other_user)
      end

      get feeds_path, headers: @authentication_header

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response.size).to eq(8)
      expect(json_response.map { |record| record["id"] }).to match_array(sleep_records.map(&:id) + other_sleep_records.flatten.map(&:id))
      expect(json_response.flat_map(&:keys).uniq).to match_array([ "id", "start_time", "end_time", "duration", "user_id" ])
    end

    it "returns an empty array if no feeds are available" do
      get feeds_path, headers: @authentication_header

      expect(response).to have_http_status(:success)
      expect(response.body).to eq("[]")
    end
  end
end
