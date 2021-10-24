require "application_system_test_case"

class MessagesTest < ApplicationSystemTestCase
  test "renders a page-worth of Message records sorted from most recent to least recent" do
    using_page_size 10 do |page_size|
      messages = Message.most_recent_first.limit page_size

      visit messages_path

      assert_css "article", count: page_size
      messages.each_with_index do |message, index|
        within "article:nth-of-type(#{index + 1})" do
          assert_text message.content.to_plain_text
        end
      end
    end
  end

  test "links to the next page-worth of Message records" do
    using_page_size 10 do |page_size|
      messages = Message.most_recent_first.offset(page_size).limit(page_size)

      visit messages_path
      click_on("Next page") { _1["rel"] == "next" }

      assert_css "article", count: page_size
      messages.each_with_index do |message, index|
        within "article:nth-of-type(#{index + 1})" do
          assert_text message.content.to_plain_text
        end
      end
    end
  end

  def using_page_size(size = Pagy::DEFAULT[:items], &block)
    original_size, Pagy::DEFAULT[:items] = Pagy::DEFAULT[:items], size

    block.call(size)
  ensure
    Pagy::DEFAULT[:items] = original_size
  end
end
