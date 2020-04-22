class UserService
  def initialize(params)
    @password = params[:password]
    @email = params[:email]
    @limit = params[:limit]
    @offset = params[:offset]
    @params = params
  end

  def register
    register_validation_params
    user = User.new(@params)
    user.save!

    user
  end

  def login
    login_validation_params
    user = User.find_by_email!(@email)
    if user.authenticate(@password)
      user
    else
      raise(StandardError.new("unauthorized"))
    end
  end

  private

  def register_validation_params
    %i[name email password password_confirmation].each do |key|
      raise(StandardError.new("invalid params")) unless @params[key].present?
    end
  end

  def login_validation_params
    %i[email password].each do |key|
      raise(StandardError.new("invalid params")) unless @params[key].present?
    end
  end
end