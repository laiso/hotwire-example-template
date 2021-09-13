require "test_helper"

class ApplicantTest < ActiveSupport::TestCase
  test "requires name" do
    applicant = Applicant.new name: ""

    valid = applicant.validate

    assert_not valid
    assert_includes applicant.errors, :name
  end

  test "allows empty Personal References relationship" do
    applicant = Applicant.new name: "An Applicant", personal_references_attributes: [{ name: "", email_address: "" }]

    valid = applicant.validate

    assert valid
  end
end
