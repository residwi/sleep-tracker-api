require "rails_helper"

RSpec.describe "Api::V1::SleepRecords", type: :request do
  let(:user) { create(:user) }

  before do
    token = api_sign_in_as(user)
    @authentication_header = { Authorization: "Bearer #{token}" }
  end

  describe "GET /api/v1/sleep_records" do
    it "returns sleep records of current user" do
      sleep_records = create_list(:sleep_record, 3, user: user)

      get api_v1_sleep_records_path, headers: @authentication_header

      most_recent_records = sleep_records.sort_by(&:created_at).reverse
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response["data"].size).to eq(3)
      expect(json_response["data"].map { |record| record["id"] }).to match_array(most_recent_records.map(&:id))
    end

    context "when paginated" do
      it "returns paginated sleep records" do
        sleep_records = create_list(:sleep_record, 10, user: user)

        get api_v1_sleep_records_path(limit: 5), headers: @authentication_header

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response["data"].size).to eq(5)
        expect(json_response["data"].map { |record| record["id"] }).to match_array(sleep_records.sort_by(&:created_at).reverse.first(5).map(&:id))
        expect(json_response["pagination"]["next"]).to be_present
      end
    end
  end

  describe "POST /api/v1/sleep_records" do
    it "creates a new sleep record for current user" do
      sleep_record_params = {
        start_time: Time.current.iso8601,
        end_time: 2.hours.from_now.iso8601
      }

      post api_v1_sleep_records_path, params: sleep_record_params, headers: @authentication_header

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(json_response["data"]).to eq(user.sleep_records.last.as_json)
    end

    it "returns an error when the record is invalid" do
      invalid_params = { start_time: nil }

      post api_v1_sleep_records_path, params: invalid_params, headers: @authentication_header

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to eq(JSON.generate({
        data: nil,
        errors: {
          start_time: [ "Start time can't be blank" ]
        }
      }))
    end

    it "returns an error when datetime format is invalid" do
      invalid_params = {
        start_time: "05/08/2025 08:00:00",
        end_time: "05/08/2025 10:00:00"
      }

      post api_v1_sleep_records_path, params: invalid_params, headers: @authentication_header

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]["start_time"]).to include("Start time must be a valid ISO8601 datetime format")
    end
  end

  describe "GET /api/v1/sleep_records/:id" do
    it "returns a specific sleep record of current user" do
      sleep_record = create(:sleep_record, user: user)

      get api_v1_sleep_record_path(sleep_record), headers: @authentication_header

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response["data"]["id"]).to eq(sleep_record.id)
    end

    it "returns an error when the record is not found" do
      get api_v1_sleep_record_path(id: 999), headers: @authentication_header

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /api/v1/sleep_records/:id" do
    it "updates a specific sleep record of current user" do
      sleep_record = create(:sleep_record, user: user)
      updated_params = { end_time: 3.hours.from_now.iso8601 }

      put api_v1_sleep_record_path(sleep_record), params: updated_params, headers: @authentication_header

      expected_response = sleep_record.reload
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response["data"]["end_time"]).to eq(expected_response.end_time.as_json)
      expect(json_response["data"]["duration"]).to eq(expected_response.duration)
    end

    it "returns an error when the record is invalid" do
      sleep_record = create(:sleep_record, user: user)
      invalid_params = { start_time: nil }

      put api_v1_sleep_record_path(sleep_record), params: invalid_params, headers: @authentication_header

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to eq(JSON.generate({
        data: nil,
        errors: {
          start_time: [ "Start time can't be blank" ]
        }
      }))
    end

    it "returns an error when datetime format is invalid" do
      sleep_record = create(:sleep_record, user: user)
      invalid_params = { end_time: "05/08/2025 10:00:00" }

      put api_v1_sleep_record_path(sleep_record), params: invalid_params, headers: @authentication_header

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]["end_time"]).to include("End time must be a valid ISO8601 datetime format")
    end
  end

  describe "DELETE /api/v1/sleep_records/:id" do
    it "deletes a specific sleep record of current user" do
      sleep_record = create(:sleep_record, user: user)

      delete api_v1_sleep_record_path(sleep_record), headers: @authentication_header

      expect(response).to have_http_status(:no_content)
      expect { sleep_record.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an error when the record is not found" do
      delete api_v1_sleep_record_path(id: 999), headers: @authentication_header

      expect(response).to have_http_status(:not_found)
    end
  end
end
