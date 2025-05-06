class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :sleep_records
  has_many :follower_relationships, class_name: "Follow", foreign_key: "follower_id"
  has_many :following_relationships, class_name: "Follow", foreign_key: "followed_id"
  has_many :following, through: :follower_relationships, source: :followed
  has_many :followers, through: :following_relationships, source: :follower

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 12 }

  normalizes :email, with: -> { it.strip.downcase }

  def follow(other_user)
    following << other_user unless self == other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end
end
