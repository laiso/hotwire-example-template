require "test_helper"

class ApplicantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @applicant = applicants(:one)
  end

  test "should get index" do
    get applicants_url
    assert_response :success
  end

  test "should get new" do
    get new_applicant_url
    assert_response :success
  end

  test "should create applicant" do
    assert_difference("Applicant.count") do
      post applicants_url, params: { applicant: { name: @applicant.name } }
    end

    assert_redirected_to applicant_url(Applicant.last)
  end

  test "should create applicant with nested personal references attributes" do
    assert_difference("Applicant.count" => +1, "PersonalReference.count" => +1) do
      post applicants_url, params: {
        applicant: {
          name: @applicant.name,
          personal_references_attributes: {
            "0" => personal_references(:one).slice(:name, :email_address),
          }
        }
      }
    end

    assert_redirected_to applicant_url(Applicant.last)
  end

  test "should show applicant" do
    get applicant_url(@applicant)
    assert_response :success
  end

  test "should get edit" do
    get edit_applicant_url(@applicant)
    assert_response :success
  end

  test "should update applicant" do
    patch applicant_url(@applicant), params: { applicant: { name: @applicant.name } }
    assert_redirected_to applicant_url(@applicant)
  end

  test "should update applicant with nested personal references attributes" do
    assert_no_difference("Applicant.count", "PersonalReference.count") do
      put applicant_path(@applicant), params: {
        applicant: {
          name: @applicant.name,
          personal_references_attributes: {
            "0" => personal_references(:one).slice(:name, :email_address, :id).merge(_destroy: true),
            "1" => personal_references(:two).slice(:name, :email_address),
          }
        }
      }
    end

    assert_redirected_to applicant_url(@applicant)
    assert_equal @applicant.personal_references.pluck(:email_address), [ personal_references(:two).email_address ]
  end

  test "should destroy applicant" do
    assert_difference("Applicant.count", -1) do
      delete applicant_url(@applicant)
    end

    assert_redirected_to applicants_url
  end
end
