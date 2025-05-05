class Follow < ApplicationRecord
  belongs_to :followed, class_name: "User", foreign_key: :followed_id
  belongs_to :follower, class_name: "User", foreign_key: :follower_id

  validates :follower_id, uniqueness: { scope: :followed_id }
  validate :not_following_self

  private

  def not_following_self
    errors.add(:follower_id, "can't follow themselves") if follower_id == followed_id
  end
end
