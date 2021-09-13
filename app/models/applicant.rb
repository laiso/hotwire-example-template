class Applicant < ApplicationRecord
  has_many :personal_references

  accepts_nested_attributes_for :personal_references,
    reject_if: :all_blank,
    allow_destroy: true

  validates :name, presence: true
end
