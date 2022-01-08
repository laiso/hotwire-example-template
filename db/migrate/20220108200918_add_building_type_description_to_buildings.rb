class AddBuildingTypeDescriptionToBuildings < ActiveRecord::Migration[7.0]
  def change
    change_table :buildings do |t|
      t.text :building_type_description
    end
  end
end
