require "rails_helper"

RSpec.describe User, type: :model do
  describe "columns" do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:email).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:password_digest).of_type(:string).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:email).unique(true) }
  end

  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:sleep_records) }
    it { is_expected.to have_many(:follower_relationships).class_name("Follow").with_foreign_key("follower_id") }
    it { is_expected.to have_many(:following_relationships).class_name("Follow").with_foreign_key("followed_id") }
    it { is_expected.to have_many(:following).through(:follower_relationships).source(:followed) }
    it { is_expected.to have_many(:followers).through(:following_relationships).source(:follower) }
  end

  describe "name validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "email validations" do
    it { is_expected.to validate_presence_of(:email) }

    describe "email uniqueness" do
      subject { create(:user) }

      it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    end

    it { is_expected.to allow_value("user@example.com").for(:email) }
    it { is_expected.not_to allow_value("invalid_email").for(:email) }
  end

  describe "password validations" do
    it "validates minimum password length of 12" do
      user = build(:user, password: "short")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 12 characters)")
    end

    it "allows updates without changing password" do
      user = create(:user)
      expect(user.update(email: "another_#{user.email}")).to be true
    end
  end

  describe "normalization" do
    it { is_expected.to normalize(:email).from("USER@EXAMPLE.COM").to("user@example.com") }
  end

  describe "#follow" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it "follows another user" do
      expect { user.follow(other_user) }.to change { user.following.count }.by(1)
      expect(user.following).to include(other_user)
    end

    it "does not allow self-following" do
      expect { user.follow(user) }.not_to change { user.following.count }
      expect(user.following).not_to include(user)
    end
  end

  describe "#unfollow" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    before do
      user.follow(other_user)
    end

    it "unfollows another user" do
      expect { user.unfollow(other_user) }.to change { user.following.count }.by(-1)
      expect(user.following).not_to include(other_user)
    end
  end

  describe "#following?" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context "when user is following another user" do
      it "returns true" do
        user.follow(other_user)
        expect(user.following?(other_user)).to be true
      end
    end

    context "when user is not following another user" do
      it "returns false" do
        expect(user.following?(other_user)).to be false
      end
    end
  end
end
