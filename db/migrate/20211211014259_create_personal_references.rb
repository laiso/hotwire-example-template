class CreatePersonalReferences < ActiveRecord::Migration[7.1]
  def change
    create_table :personal_references do |t|
      t.text :name
      t.text :email_address
      t.references :applicant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
