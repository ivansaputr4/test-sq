class CreateDoctors < ActiveRecord::Migration[5.2]
  def change
    create_table :doctors do |t|
      t.string :name
      t.integer :specialist, limit: 2, default: 1

      t.timestamps
    end

    add_index :doctors, :specialist
  end
end
