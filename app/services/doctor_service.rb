class DoctorService
  def initialize(params)
    @params = params
    @doctor = params[:doctor]
  end

  def bulk_get
    doctors = Doctor

    s_specialist = @params[:specialist]
    if s_specialist.present?
      doctors = doctors.where(specialist: s_specialist)
    end

    limit = (@params[:limit] || 20).to_i
    offset = (@params[:offset] || 0).to_i
    doctors = doctors.limit(limit).offset(offset)

    [doctors, offset, limit]
  end

  def book
    book_validation_params

    current_time = Time.now.localtime
    schedule_session = @params[:schedule_session].to_i
    booking_date = @params[:booking_date].to_date
    doctor_schedule = @doctor.doctor_schedules.where(day_of_week: booking_date.wday, schedule_session: schedule_session).first

    # Validation check doctor schedule
    unless doctor_schedule
      raise(StandardError.new('Dokter tidak memiliki jadwal sesi pada hari tersebut. Silahkan memesan jadwal sesi yang lain'))
    end

    booking_time = booking_date.to_time.change(hour: doctor_schedule.start_hour)
    # Validation booking date less than current time
    if booking_time < current_time
      raise(StandardError.new('Tidak boleh memesan jadwal sesi kurang dari waktu sekarang'))
    end

    # Validation booking session less than 30 minutes before Doctor's schedule session is starting
    if (booking_time.to_i - current_time.to_i) < 30.minutes
      raise(StandardError.new('Silahkan memesan jadwal sesi yang lain'))
    end

    booking_schedules = @doctor.booking_schedules.where(booking_date: booking_date, schedule_session: schedule_session)
    # Validation maximum patient per session per doctor
    if booking_schedules.count >= BookingSchedule::MAXIMUM_PATIENT_LIMIT
      raise(StandardError.new('Jadwal dokter hari ini sudah mencapai batas maksimum pasien'))
    end

    # Validation already booked in current session
    if booking_schedules.pluck(:patient_id).include?(@params[:patient_id])
      raise(StandardError.new('Kamu sudah memesan pada jadwal sesi ini'))
    end

    booking_schedule = BookingSchedule.new(
      doctor_id: @doctor.id,
      booking_date: booking_date,
      schedule_session: schedule_session,
      patient_id: @params[:patient_id]
    )

    booking_schedule.save!
    booking_schedule
  end

  def get_schedules
    schedules_validation_params
    booking_date = @params[:booking_date].present? ? Date.parse(@params[:booking_date]) : Date.today
    @booking_schedules = @doctor.booking_schedules.where(booking_date: booking_date)

    if @params[:schedule_session].present?
      @booking_schedules = @booking_schedules.where(schedule_session: @params[:schedule_session])
    end

    @booking_schedules
  end

  def get_weekly_schedules
    schedules_validation_params

    @doctor.doctor_schedules
  end

  private

  def book_validation_params
    %i[booking_date schedule_session doctor patient_id].each do |key|
      raise(StandardError.new("invalid params")) unless @params[key].present?
    end
  end

  def schedules_validation_params
    %i[doctor].each do |key|
      raise(StandardError.new("invalid params")) unless @params[key].present?
    end
  end
end