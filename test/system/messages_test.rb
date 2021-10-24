require "application_system_test_case"

class MessagesTest < ApplicationSystemTestCase
  test "renders all Message records sorted from most recent to least recent" do
    messages = Message.most_recent_first

    visit messages_path

    assert_css "article", count: messages.size
    messages.each_with_index do |message, index|
      within "article:nth-of-type(#{index + 1})" do
        assert_text message.content.to_plain_text
      end
    end
  end
end
