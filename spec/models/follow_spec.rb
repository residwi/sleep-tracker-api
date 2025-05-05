require "rails_helper"

RSpec.describe Follow, type: :model do
  describe "columns" do
    it { is_expected.to have_db_column(:follower_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:followed_id).of_type(:integer).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index([ :followed_id, :follower_id ]).unique(true) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:follower).class_name("User").with_foreign_key(:follower_id) }
    it { is_expected.to belong_to(:followed).class_name("User").with_foreign_key(:followed_id) }
  end

  describe "validations" do
    context "uniqueness" do
      subject { create(:follow) }

      it { is_expected.to validate_uniqueness_of(:follower_id).scoped_to(:followed_id) }
    end

    context "not following self" do
      it "returns erorr if follower_id is the same as followed_id" do
        user = create(:user)
        follow = build(:follow, follower_id: user.id, followed_id: user.id)

        expect(follow).not_to be_valid
        expect(follow.errors[:follower_id]).to include("can't follow themselves")
      end
    end
  end
end
