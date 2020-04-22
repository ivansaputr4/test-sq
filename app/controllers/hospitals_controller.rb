class HospitalsController < ApplicationController
  include JsonResultHelper

  before_action :find_hospital, only: %i[show update]

  # GET /hospitals
  def index
    @hospitals, offset, limit = HospitalService.new(hospital_params).bulk_get

    meta = {
      offset: offset,
      limit: limit,
      total: @hospitals.count
    }

    render json: success_serializer(hospitals_result, :ok, meta), status: :ok
  end

  # GET /hospitals/:id
  def show
    render json: success_serializer(hospital_result, :ok), status: :ok
  end

  # POST /hospitals
  def create
    @hospital = Hospital.new(hospital_params)
    if @hospital.save
      render json: success_serializer(hospital_result, :created), status: :created
    else
      render json: failed_serializer(@hospital.errors.full_messages, :unprocessable_entity), status: :unprocessable_entity
    end
  end

  # PATCH /hospitals/:id
  def update
    if @hospital.update(hospital_params)
      render json: success_serializer(hospital_result, :ok), status: :ok
    else
      render json: failed_serializer(@hospital.errors.full_messages, :unprocessable_entity), status: :unprocessable_entity
    end
  end

  private

  def policy_authorize!
    case action_name.to_sym
    when :create
      admin_policy
    else
      true
    end
  end

  def find_hospital
    @hospital = Hospital.find_by_id!(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def hospital_params
    params.permit(
      :name, :area, :address, :limit, :offset
    )
  end

  def hospital_result(hospital = nil)
    hospital = hospital || @hospital
    {
      id:         hospital.id,
      name:       hospital.name,
      address:    hospital.address,
      area:       hospital.area
    }.merge(time_result(hospital))
  end

  def hospitals_result
    @hospitals.map do |hospital|
      hospital_result(hospital)
    end
  end
end
