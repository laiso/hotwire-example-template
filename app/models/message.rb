class Message < ApplicationRecord
  has_rich_text :content

  with_options presence: true do
    validates :author
    validates :content
  end
end
