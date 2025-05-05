class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :sleep_records

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 12 }

  normalizes :email, with: -> { it.strip.downcase }
end
