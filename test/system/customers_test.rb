require "application_system_test_case"

class CustomersTest < ApplicationSystemTestCase
  test "renders all Customers" do
    alice, bob, chuck = customers :alice, :bob, :chuck

    visit customers_path

    within :table, "Customers" do
      assert_css "tr:nth-child(1)", text: alice.name
      assert_css "tr:nth-child(2)", text: bob.name
      assert_css "tr:nth-child(3)", text: chuck.name
    end
  end

  test "filters Customers by search query text" do
    alice, bob, chuck = customers :alice, :bob, :chuck

    visit customers_path
    within "nav" do
      fill_in "Search", with: "alice"
      click_on "Submit"
    end

    within :table, "Customers" do
      assert_css "tr", text: alice.name
      assert_no_css "tr", text: bob.name
      assert_no_css "tr", text: chuck.name
    end
  end
end
