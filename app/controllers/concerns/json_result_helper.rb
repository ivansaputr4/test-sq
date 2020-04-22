module JsonResultHelper
  extend ActiveSupport::Concern

  def doctor_result(doctor = nil)
    {
      id:         doctor.id,
      name:       doctor.name,
      specialist: doctor.specialist
    }
  end

  def doctor_with_time_result(doctor = nil)
    doctor = doctor || @doctor
    doctor_result(doctor).merge(time_result(doctor))
  end

  def user_result(user = nil)
    usr = user || @user
    {
      id:         usr.id,
      name:       usr.name,
      email:      usr.email
    }
  end

  def user_with_time_result(user = nil)
    user = user || @user
    user_result(user).merge(time_result(user))
  end

  def time_result(model)
    {
      created_at: model.created_at.to_s,
      updated_at: model.updated_at.to_s
    }
  end
end
