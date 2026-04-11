class Inquiry < ApplicationRecord
  belongs_to :assignee, class_name: "User"

  has_many :feature_assignments, dependent: :destroy
  has_many :features, through: :feature_assignments

  has_many :inquiry_status_histories, dependent: :destroy

  enum :status, { unhandled: 0, in_progress: 1, completed: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

  validates :title, presence: true
  validates :body, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :due_date, presence: true
  validates :assignee_id, presence: true

  validate :features_must_be_present

  before_validation :set_inquiry_no, on: :create

  scope :active, -> { where(deleted_at: nil) }

  def soft_delete!(reason:)
    update!(deleted_at: Time.current, delete_reason: reason)
  end

  private

  def set_inquiry_no
    return if inquiry_no.present?

    next_number = Inquiry.maximum(:id).to_i + 1
    self.inquiry_no = format("INQ%05d", next_number)
  end

  def features_must_be_present
    errors.add(:features, "を1つ以上選択してください") if features.blank?
  end
end