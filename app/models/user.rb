class User < ApplicationRecord
  has_secure_password

  has_many :plants, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::PATTERN }
end
