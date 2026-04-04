class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.strip }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true

  def approved?
    approved_at.present?
  end

  def rejected?
    rejected_at.present?
  end

  def pending?
    approved_at.blank? && rejected_at.blank?
  end
end
