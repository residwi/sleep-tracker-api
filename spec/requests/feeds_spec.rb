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

    it "returns the feeds of the current user and their following from the previous week, sorted by duration" do
      one_week_ago = 1.week.ago
      two_weeks_ago = 2.weeks.ago

      sleep_record_8_hours = create(:sleep_record, user: other_users[0], start_time: one_week_ago + 1.day, end_time: one_week_ago + 1.day + 8.hours)
      sleep_record_6_hours = create(:sleep_record, user: other_users[1], start_time: one_week_ago + 2.days, end_time: one_week_ago + 2.days + 6.hours)
      sleep_record_9_hours = create(:sleep_record, user: other_users[2], start_time: one_week_ago + 3.days, end_time: one_week_ago + 3.days + 9.hours)
      create(:sleep_record, user: other_users[0], start_time: two_weeks_ago, end_time: two_weeks_ago + 7.hours)
      create(:sleep_record, user: user, start_time: one_week_ago + 1.day, end_time: one_week_ago + 1.day + 7.hours)

      get feeds_path, headers: @authentication_header

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response["data"].size).to eq(3)
      expect(json_response["data"][0]["id"]).to eq(sleep_record_9_hours.id)
      expect(json_response["data"][1]["id"]).to eq(sleep_record_8_hours.id)
      expect(json_response["data"][2]["id"]).to eq(sleep_record_6_hours.id)
      expect(json_response["data"][0]["user"]).to be_present
      expect(json_response["data"][0]["user"]["id"]).to eq(other_users[2].id)
      expect(json_response["data"][0]["user"]["name"]).to eq(other_users[2].name)
      expect(json_response["data"].flat_map(&:keys).uniq).to match_array([ "id", "start_time", "end_time", "duration", "user" ])
    end

    it "returns an empty array if no feeds are available" do
      get feeds_path, headers: @authentication_header

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response["data"]).to be_empty
      expect(json_response["pagination"]["next"]).to be_nil
    end

    context "when paginated" do
      it "returns paginated feeds" do
        sleep_records = 10.times.map do |i|
          i += 1

          create(:sleep_record,
            user: other_users[i % 3],
            start_time: 1.week.ago + i.hours,
            end_time: 1.week.ago + i.hours + (10 - i).hours
          )
        end

        get feeds_path(limit: 5), headers: @authentication_header

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response["data"].size).to eq(5)
        expect(json_response["data"].map { |record| record["id"] }).to match_array(sleep_records.sort_by(&:duration).reverse.first(5).map(&:id))
        expect(json_response["pagination"]["next"]).to be_present
      end
    end
  end
end
