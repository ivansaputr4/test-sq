class DoctorsController < ApplicationController
  include JsonResultHelper

  before_action :find_doctor, except: %i[create index update_schedule]

  # GET /doctors
  def index
    @doctors, offset, limit = DoctorService.new(doctor_params).bulk_get

    meta = {
      offset: offset,
      limit: limit,
      total: @doctors.count
    }

    render json: success_serializer(doctors_result, :ok, meta), status: :ok
  end

  # GET /doctors/:id
  def show
    render json: success_serializer(doctor_with_time_result, :ok), status: :ok
  end

  # POST /doctors
  def create
    @doctor = Doctor.new(doctor_params)
    if @doctor.save
      render json: success_serializer(doctor_with_time_result, :created), status: :created
    else
      render json: failed_serializer(@doctor.errors.full_messages, :unprocessable_entity), status: :unprocessable_entity
    end
  end

  # PATCH /doctors/:id
  def update
    if @doctor.update(doctor_params)
      render json: success_serializer(doctor_with_time_result, :ok), status: :ok
    else
      render json: failed_serializer(@doctor.errors.full_messages, :unprocessable_entity), status: :unprocessable_entity
    end
  end

  # POST /doctors/:id/book
  def book
    args = book_params.to_h.merge({ doctor: @doctor, patient_id: @current_user.id })
    @booking_schedule = DoctorService.new(args).book

    render json: success_serializer(booking_schedule_result, :created), status: :created
  rescue => e
    render json: failed_serializer(e.message, :unprocessable_entity), status: :unprocessable_entity
  end

  # GET /doctors/:id/schedules
  def schedules
    @booking_schedules = DoctorService.new(book_params.merge({ doctor: @doctor })).get_schedules

    render json: success_serializer(booking_schedules_result, :ok), status: :ok
  end

  # GET /doctors/:id/weekly_schedules
  def weekly_schedules
    @doctor_schedules = DoctorService.new({ doctor: @doctor }).get_weekly_schedules

    render json: success_serializer(doctor_schedules_result, :ok), status: :ok
  end

  # POST /doctors/:id/schedules
  def create_schedule
    doctor_schedule_params[:day_of_weeks].each do |day_of_week|
      @doctor_schedule = DoctorSchedule.new(
        day_of_week: DoctorSchedule.day_of_weeks[day_of_week],
        schedule_session: doctor_schedule_params[:schedule_session].to_i,
        start_hour: doctor_schedule_params[:start_hour],
        end_hour: doctor_schedule_params[:end_hour],
        doctor_id: @doctor.id
      )

      @doctor_schedule.save!
    end

    render json: success_serializer(doctor_schedule_result, :created), status: :created
  rescue => e
    render json: failed_serializer(e.message, :unprocessable_entity), status: :unprocessable_entity
  end

  # PATCH /doctors/:id/schedules/:schedule_id
  def update_schedule
    @doctor_schedule = DoctorSchedule.find_by_id(params[:schedule_id])
    if @doctor_schedule.update(doctor_schedule_params)
      render json: success_serializer(doctor_schedule_result, :created), status: :created
    else
      render json: failed_serializer(@doctor_schedule.errors.full_messages, :unprocessable_entity), status: :unprocessable_entity
    end
  end

  private

  def policy_authorize!
    case action_name.to_sym
    when :create, :update, :create_schedule, :update_schedule
      admin_policy
    else
      true
    end
  end

  def find_doctor
    @doctor = Doctor.find_by_id!(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def doctor_params
    params.permit(
      :name, :specialist, :limit, :offset
    )
  end

  def book_params
    params.permit(
      :booking_date, :schedule_session
    )
  end

  def doctor_schedule_params
    params.permit(
      :day_of_week, :schedule_session, :start_hour, :end_hour, day_of_weeks: []
    )
  end

  def doctors_result
    @doctors.map do |doctor|
      doctor_with_time_result(doctor)
    end
  end

  def booking_schedule_result(booking_schedule = nil)
    booking_schedule = booking_schedule || @booking_schedule
    {
      id: booking_schedule.id,
      booking_date: booking_schedule.booking_date,
      schedule_session: booking_schedule.schedule_session,
      doctor: doctor_result(booking_schedule.doctor),
      patient: user_result(booking_schedule.patient),
      created_at: booking_schedule.created_at.to_s,
      updated_at: booking_schedule.updated_at.to_s
    }
  end

  def booking_schedules_result
    @booking_schedules.map do |booking_schedule|
      booking_schedule_result(booking_schedule)
    end
  end

  def doctor_schedule_result(doctor_schedule = nil)
    doctor_schedule = doctor_schedule || @doctor_schedule
    {
      day_of_week: doctor_schedule.day_of_week,
      schedule_session: doctor_schedule.schedule_session,
      start_hour: doctor_schedule.start_hour,
      end_hour: doctor_schedule.end_hour,
      created_at: doctor_schedule.created_at.to_s,
      updated_at: doctor_schedule.updated_at.to_s
    }
  end

  def doctor_schedules_result
    @doctor_schedules.map do |doctor_schedule|
      doctor_schedule_result(doctor_schedule)
    end
  end
end
