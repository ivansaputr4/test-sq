class CreateHospitals < ActiveRecord::Migration[5.2]
  def change
    create_table :hospitals do |t|
      t.string :name
      t.string :address
      t.integer :area, limit: 2

      t.timestamps
    end

    add_index :hospitals, [:area, :name]
  end
end
