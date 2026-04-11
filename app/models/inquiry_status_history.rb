class InquiryStatusHistory < ApplicationRecord
  belongs_to :inquiry
  belongs_to :changed_by, class_name: "User"

  enum :from_status, { unhandled: 0, in_progress: 1, completed: 2 }, prefix: true
  enum :to_status, { unhandled: 0, in_progress: 1, completed: 2 }, prefix: true

  validates :reason, presence: true
end