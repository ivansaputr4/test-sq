class CreateBookingSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :booking_schedules do |t|
      t.date :booking_date
      t.integer :doctor_id
      t.integer :schedule_session, limit: 2, default: 1
      t.integer :patient_id
      t.integer :state, limit: 2, default: 1

      t.timestamps
    end

    add_index :booking_schedules, [:doctor_id, :booking_date, :schedule_session], name: 'idx_book_sche_doctor_id_and_booking_date_and_sche_session'
    add_index :booking_schedules, :patient_id
  end
end
