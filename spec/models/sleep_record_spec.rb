require "rails_helper"

RSpec.describe SleepRecord, type: :model do
  describe "columns" do
    it { is_expected.to have_db_column(:start_time).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:end_time).of_type(:datetime) }
    it { is_expected.to have_db_column(:duration).of_type(:integer) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_time) }

    describe "end_time validations" do
      subject { build(:sleep_record) }

      it { is_expected.to validate_comparison_of(:end_time).is_greater_than(:start_time) }

      it "allows nil end_time" do
        record = build(:sleep_record, start_time: Time.current, end_time: nil)
        expect(record).to be_valid
      end

      it "returns empty errors for end_time if start_time is nil" do
        record = build(:sleep_record, start_time: nil, end_time: 2.hours.from_now)
        expect(record).not_to be_valid
        expect(record.errors[:end_time]).to eq([])
      end
    end
  end

  describe "callbacks" do
    describe "#calculate_duration" do
      it "calculates duration before saving" do
        record = build(:sleep_record, start_time: Time.current, end_time: 2.hours.from_now)
        record.save
        expect(record.duration).to eq(120)
      end

      it "does not calculate duration if end_time is nil" do
        record = build(:sleep_record, start_time: Time.current, end_time: nil)
        record.save
        expect(record.duration).to be_nil
      end
    end
  end
end
