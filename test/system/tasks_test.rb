require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  test "create a Task" do
    details = "Get started!"

    visit tasks_path
    within_section("To-do (0)") { toggle_disclosure "Add task" }
    within_disclosure "Add task", expanded: true do
      fill_in "Details", with: details
      click_on "Create Task"
    end

    within_section("To-do (1)") { assert_button details }
    toggle_disclosure "Add task"
    within_disclosure("Add task") { assert_field "Details", with: "" }
  end

  test "mark a Task as Done" do
    task = Task.create! details: "Write a test!"

    visit tasks_path
    within_section("To-do (1)") { click_on task.details }

    assert_selector :section, "To-do (0)"
    within_section("Done (1)") { assert_button task.details }
  end

  test "mark a Task as To-do" do
    task = Task.create! details: "Write a test!", done_at: 1.week.ago

    visit tasks_path
    within_section("Done (1)") { click_on task.details }

    assert_selector :section, "Done (0)"
    within_section("To-do (1)") { assert_button task.details }
  end

  test "edit a Task" do
    Task.create! details: "Get started!"

    visit tasks_path
    within_section("To-do (1)") { click_on "Edit" }
    fill_in("Details", with: "Finish up!").then { click_on "Update Task" }

    within_section("To-do (1)") { assert_button "Finish up!" }
  end

  test "preserves fields while marking a Task as done" do
    task = Task.create! details: "Write a test!", done_at: 1.week.ago
    preserved = "Not started yet!"

    visit tasks_path
    within_section("To-do (0)") { toggle_disclosure "Add task" }
    within_disclosure("Add task") { fill_in "Details", with: preserved }
    within_section("Done (1)") { click_on task.details }

    assert_selector :section, "Done (0)"
    within_section "To-do (1)" do
      assert_field "Details", with: preserved
      assert_button task.details
    end
  end

  test "preserves scroll depth while marking a Task as done" do
    *, task = Task.create! 1.upto(100).map { { details: "Task ##{_1}" } }

    visit tasks_path
    scroll_to find_button task.details

    assert_no_changes -> { scroll_top } do
      click_on task.details
    end
  end

  def scroll_top
    evaluate_script <<~JS, page
      arguments[0].scrollTop
    JS
  end
end
