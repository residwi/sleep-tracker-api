require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /users" do
    it "returns a list of users" do
      create_list(:user, 3)

      get users_path

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response["data"].size).to eq(3)
      expect(json_response["data"].map { |user| user["id"] }).to match_array(User.all.map(&:id))
      expect(json_response["data"].flat_map(&:keys).uniq).to match_array([ "id", "name" ])
    end

    context "when paginated" do
      it "returns paginated users" do
        create_list(:user, 10)

        get users_path(limit: 5)

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response["data"].size).to eq(5)
        expect(json_response["data"].map { |user| user["id"] }).to match_array(User.order(id: :asc).limit(5).pluck(:id))
        expect(json_response["pagination"]["next"]).to be_present
      end
    end
  end

  describe "GET /users/:id" do
    it "returns a specific user" do
      user = create(:user)

      get user_path(user)

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response["id"]).to eq(user.id)
      expect(json_response.keys).to match_array([ "id", "name" ])
    end

    it "returns 404 if user not found" do
      get user_path(id: 9999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /users/:id/sleep_records" do
    let(:user) { create(:user) }

    before do
      token = api_sign_in_as(user)
      @authentication_header = { Authorization: "Bearer #{token}" }
    end

    it "returns sleep records of a user" do
      sleep_records = create_list(:sleep_record, 3, user: user)

      get sleep_records_user_path(user), headers: @authentication_header

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response["data"].size).to eq(3)
      expect(json_response["data"].map { |record| record["id"] }).to match_array(sleep_records.map(&:id))
      expect(json_response["data"].flat_map(&:keys).uniq).to match_array([ "id", "start_time", "end_time", "duration", "created_at" ])
    end

    it "returns 404 if user not found" do
      get sleep_records_user_path(id: 9999), headers: @authentication_header
      expect(response).to have_http_status(:not_found)
    end

    context "when paginated" do
      it "returns paginated sleep records" do
        sleep_records = create_list(:sleep_record, 10, user: user)

        get sleep_records_user_path(user, limit: 5), headers: @authentication_header

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response["data"].size).to eq(5)
        expect(json_response["data"].map { |record| record["id"] }).to match_array(sleep_records.sort_by(&:created_at).reverse.first(5).map(&:id))
        expect(json_response["pagination"]["next"]).to be_present
      end
    end
  end

  describe "POST /users/:id/follow" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    before do
      token = api_sign_in_as(user)
      @authentication_header = { Authorization: "Bearer #{token}" }
    end

    it "follows another user" do
      post follow_user_path(other_user), headers: @authentication_header

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(json_response["message"]).to eq("Successfully followed user")
      expect(user.following).to include(other_user)
    end

    it "does not allow self-following" do
      post follow_user_path(user), headers: @authentication_header

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to eq("Unable to follow user")
    end
  end

  describe "DELETE /users/:id/unfollow" do
    it "unfollows another user" do
      user = create(:user)
      other_user = create(:user)
      user.follow(other_user)

      token = api_sign_in_as(user)

      delete unfollow_user_path(other_user), headers: { Authorization: "Bearer #{token}" }

      expect(response).to have_http_status(:no_content)
      expect(user.following).not_to include(other_user)
    end
  end

  describe "GET /users/:id/followers" do
    it "returns the followers of a user" do
      user = create(:user)
      followers = create_list(:user, 3)
      followers.each do |follower|
        create(:follow, follower: follower, followed: user)
      end

      get followers_user_path(user)

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response["data"].size).to eq(3)
      expect(json_response["data"].map { |f| f["id"] }).to match_array(followers.map(&:id))
    end

    context "when paginated" do
      it "returns paginated followers" do
        user = create(:user)
        followers = create_list(:user, 10)
        followers.each do |follower|
          create(:follow, follower: follower, followed: user)
        end

        get followers_user_path(user, limit: 5)

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response["data"].size).to eq(5)
        expect(json_response["data"].map { |f| f["id"] }).to match_array(followers.sort_by(&:created_at).reverse.first(5).map(&:id))
        expect(json_response["pagination"]["next"]).to be_present
      end
    end
  end

  describe "GET /users/:id/following" do
    it "returns the users that a user is following" do
      user = create(:user)
      followed_users = create_list(:user, 3)
      followed_users.each do |followed_user|
        create(:follow, follower: user, followed: followed_user)
      end

      get following_user_path(user)

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response["data"].size).to eq(3)
      expect(json_response["data"].map { |f| f["id"] }).to match_array(followed_users.map(&:id))
    end

    context "when paginated" do
      it "returns paginated following" do
        user = create(:user)
        followed_users = create_list(:user, 10)
        followed_users.each do |followed_user|
          create(:follow, follower: user, followed: followed_user)
        end

        get following_user_path(user, limit: 5)

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response["data"].size).to eq(5)
        expect(json_response["data"].map { |f| f["id"] }).to match_array(followed_users.sort_by(&:created_at).reverse.first(5).map(&:id))
        expect(json_response["pagination"]["next"]).to be_present
      end
    end
  end
end
