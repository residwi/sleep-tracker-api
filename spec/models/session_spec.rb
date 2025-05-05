require "rails_helper"

RSpec.describe Session, type: :model do
  describe "columns" do
    it { is_expected.to have_db_column(:user_agent).of_type(:string) }
    it { is_expected.to have_db_column(:ip_address).of_type(:string) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "callbacks" do
    it "sets user_agent and ip_address before create" do
      user_agent = "Mozilla/5.0"
      ip_address = "127.0.0.1"

      Current.user_agent = user_agent
      Current.ip_address = ip_address

      session = create(:session)

      expect(session.user_agent).to eq(user_agent)
      expect(session.ip_address).to eq(ip_address)
    end
  end
end
