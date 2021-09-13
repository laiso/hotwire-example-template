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
    within "fieldset:nth-of-type(1)", text: "Personal Reference" do
      fill_in "Name", with: "Friend"
      fill_in "Email address", with: "friend@example.com"
    end

    assert_no_button "Destroy"

    click_on "Add another personal reference"

    assert_button "Destroy", count: 1

    within "fieldset:nth-of-type(2)", text: "Personal Reference" do
      fill_in "Name", with: "Enemy"
      fill_in "Email address", with: "enemy@example.com"
    end
    click_on "Create Applicant"

    assert_text "Applicant was successfully created"
    assert_text "friend@example.com"
    assert_text "enemy@example.com"
  end

  test "hides nested attributes for Personal References" do
    visit new_applicant_path

    click_on "Add another personal reference"
    within "fieldset:nth-of-type(2)", text: "Personal Reference" do
      fill_in "Name", with: "Enemy"
      fill_in "Email address", with: "enemy@example.com"
      click_on "Destroy"
    end

    assert_no_field "Name", with: "Enemy"
    assert_no_field "Email address", with: "enemy@example.com"
    assert_no_button "Destroy"
  end

  test "rejects invalid nested attributes for Personal References when creating" do
    visit new_applicant_path

    fill_in "Name", with: "New Applicant", match: :first
    within "fieldset:nth-of-type(1)", text: "Personal Reference" do
      fill_in "Name", with: ""
      fill_in "Email address", with: "friend@example.com"
    end

    click_on "Add another personal reference"

    within "fieldset:nth-of-type(2)", text: "Personal Reference" do
      fill_in "Name", with: "Enemy"
      fill_in "Email address", with: "enemy@example.com"
      click_on "Destroy"
    end
    click_on "Create Applicant"

    assert_text "1 error prohibited this applicant from being saved"
    assert_field "Email address", with: "friend@example.com"
    assert_no_button "Destroy"
    assert_no_field "Email address", with: "enemy@example.com"
  end

  test "deletes nested attributes for Personal References when updating" do
    visit edit_applicant_path(@applicant)

    click_on "Add another personal reference"
    within "fieldset:nth-of-type(2)", text: "Personal Reference" do
      fill_in "Name", with: "Enemy"
      fill_in "Email address", with: "enemy@example.com"
      click_on "Destroy"
    end
    click_on "Update Applicant"

    assert_text "Applicant was successfully updated"
    assert_no_text "enemy@example.com"
  end
end
