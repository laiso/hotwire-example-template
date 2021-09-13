require "application_system_test_case"

class ApplicantsTest < ApplicationSystemTestCase
  setup do
    @applicant = applicants(:one)
  end

  test "visiting the index" do
    visit applicants_url
    assert_selector "h1", text: "Applicants"
  end

  test "should create applicant" do
    visit applicants_url
    click_on "New applicant"

    fill_in "Name", with: @applicant.name, match: :first
    click_on "Create Applicant"

    assert_text "Applicant was successfully created"
    click_on "Back"
  end

  test "should update Applicant" do
    visit applicant_url(@applicant)
    click_on "Edit this applicant", match: :first

    fill_in "Name", with: @applicant.name, match: :first
    click_on "Update Applicant"

    assert_text "Applicant was successfully updated"
    click_on "Back"
  end

  test "should destroy Applicant" do
    visit applicant_url(@applicant)
    click_on "Destroy this applicant", match: :first

    assert_text "Applicant was successfully destroyed"
  end

  test "accepts nested attributes for Personal References when creating" do
    visit new_applicant_path

    fill_in "Name", with: "New Applicant", match: :first
    within "fieldset", text: "Personal Reference" do
      fill_in "Name", with: "Friend"
      fill_in "Email address", with: "friend@example.com"
    end
    click_on "Create Applicant"

    assert_text "Applicant was successfully created"
    assert_text "friend@example.com"
  end

  test "deletes nested attributes for Personal References when updating" do
    personal_reference = @applicant.personal_references.first

    visit edit_applicant_path(@applicant)

    click_on "Destroy"
    click_on "Update Applicant"

    assert_text "Applicant was successfully updated"
    assert_no_text personal_reference.email_address
  end
end
