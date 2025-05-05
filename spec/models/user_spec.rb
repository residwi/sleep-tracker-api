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
end
