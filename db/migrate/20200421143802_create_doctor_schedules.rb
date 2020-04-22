class CreateDoctorSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :doctor_schedules do |t|
      t.integer :day_of_week, limit: 2
      t.integer :schedule_session, limit: 2, default: 1
      t.integer :start_hour, limit: 2
      t.integer :end_hour, limit: 2
      t.integer :doctor_id

      t.timestamps
    end

    add_index :doctor_schedules, [:doctor_id, :day_of_week, :schedule_session], name: 'idx_doc_sche_doctor_id_and_day_of_week_and_sche_session'
  end
end
