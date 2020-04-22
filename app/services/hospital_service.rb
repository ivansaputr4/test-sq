class HospitalService
  def initialize(params)
    @params = params
  end

  def bulk_get
    hospitals = Hospital

    s_area = @params[:area]&.downcase
    if s_area.present?
      hospitals = hospitals.where(area: s_area)
    end

    limit = (@params[:limit] || 20).to_i
    offset = (@params[:offset] || 0).to_i
    hospitals = hospitals.limit(limit).offset(offset)

    [hospitals, offset, limit]
  end
end