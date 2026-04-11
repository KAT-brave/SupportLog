class Feature < ApplicationRecord
  has_many :feature_assignments, dependent: :destroy
  has_many :inquiries, through: :feature_assignments

  validates :name, presence: true, uniqueness: true
end