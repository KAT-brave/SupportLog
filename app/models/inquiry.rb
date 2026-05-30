class Inquiry < ApplicationRecord
  belongs_to :assignee, class_name: "User", foreign_key: :assignee_id
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true

  has_many :feature_assignments, dependent: :destroy
  has_many :features, through: :feature_assignments

  has_many :inquiry_status_histories, dependent: :destroy

  enum :status, { unhandled: 0, in_progress: 1, completed: 2 }
  enum :priority, { incident: 0, high: 1, medium: 2, low: 3 }

  validates :title, presence: true, length: { maximum: 100 }
  validates :body, presence: true, length: { maximum: 5000 }
  validates :status, presence: true
  validates :priority, presence: true
  validates :due_date, presence: true
  validates :assignee_id, presence: true
  validates :response_content, length: { maximum: 5000 }, allow_blank: true
  validates :customer_name, length: { maximum: 100 }, allow_blank: true
  validates :phone_number, length: { maximum: 30 }, allow_blank: true
  validates :inquiry_no, uniqueness: true, allow_nil: true

  validate :features_must_be_present

  after_create :set_inquiry_no

  scope :active, -> { where(deleted_at: nil) }

  STATUS_LABELS = {
    "unhandled" => "未対応",
    "in_progress" => "対応中",
    "completed" => "完了"
  }.freeze

  PRIORITY_LABELS = {
    "incident" => "障害",
    "high" => "高",
    "medium" => "中",
    "low" => "低"
  }.freeze

  def self.status_i18n(status)
    STATUS_LABELS[status.to_s] || status.to_s
  end

  def self.priority_i18n(priority)
    PRIORITY_LABELS[priority.to_s] || priority.to_s
  end

  def soft_delete!(reason:, deleted_by: nil)
    update_columns(
      deleted_at: Time.current,
      delete_reason: reason,
      deleted_by_id: deleted_by&.id,
      updated_at: Time.current
    )
  end

  def status_i18n
    self.class.status_i18n(status)
  end

  def priority_i18n
    self.class.priority_i18n(priority)
  end

  private

  def set_inquiry_no
    update_column(:inquiry_no, format("No.%05d", id))
  end

  def features_must_be_present
    errors.add(:features, "を1つ以上選択して下さい") if features.blank?
  end
end
