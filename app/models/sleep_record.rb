class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :start_time, presence: true
  validates :end_time, comparison: { greater_than: :start_time }, allow_nil: true, if: -> { start_time.present? }

  before_save :calculate_duration

  private

  def calculate_duration
    if start_time.present? && end_time.present?
      self.duration = ((end_time - start_time) / 60).to_i
    end
  end
end
