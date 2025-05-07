class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :start_time, presence: true
  validates :end_time, comparison: { greater_than: :start_time }, allow_nil: true, if: -> { start_time.present? }
  validate :no_active_sleep_record

  before_save :calculate_duration

  private

  def calculate_duration
    if start_time.present? && end_time.present?
      self.duration = ((end_time - start_time) / 60).to_i
    end
  end

  def no_active_sleep_record
    user_active_sleep_record = SleepRecord
      .where("start_time <= ? AND end_time IS NULL", start_time)
      .where(user_id: user_id)

    if user_active_sleep_record.exists?
      errors.add(:base, "You already have an active sleep record.")
    end
  end
end
