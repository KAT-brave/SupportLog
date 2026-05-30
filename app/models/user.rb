class User < ApplicationRecord
  DEMO_ADMIN_EMAILS = [
    "demo-admin@example.com",
    "demo-sub-admin@example.com"
  ].freeze

  has_secure_password

  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  has_many :sessions, dependent: :destroy

  has_many :assigned_inquiries,
           class_name: "Inquiry",
           foreign_key: :assignee_id,
           inverse_of: :assignee,
           dependent: :restrict_with_error

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.strip }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true

  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  def demo_admin_account?
    email_address.in?(DEMO_ADMIN_EMAILS)
  end

  def approved?
    approved_at.present?
  end

  def rejected?
    rejected_at.present?
  end

  def pending?
    approved_at.blank? && rejected_at.blank?
  end

  def deleted?
    deleted_at.present?
  end

  def display_name
    base_name = name.presence || email_address

    deleted? ? "#{base_name}（削除ユーザー）" : base_name
  end

  def deletable_by_admin?
    assigned_inquiries.active.where.not(status: :completed).none?
  end

  def soft_delete!
    update!(deleted_at: Time.current, approved_at: nil)
    sessions.destroy_all
  end
end
