class Applicant < ApplicationRecord
  has_many :personal_references

  accepts_nested_attributes_for :personal_references,
    reject_if: :all_blank

  validates :name, presence: true
end
