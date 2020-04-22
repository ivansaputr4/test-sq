class UsersController < ApplicationController
  include JsonResultHelper

  before_action :find_user, except: %i[create index login]

  # GET /users
  def index
    limit = (@limit || 20).to_i
    offset = @offset.to_i
    @users = User.limit(limit).offset(offset)

    meta = {
      offset: offset,
      limit: limit,
      total: @users.count
    }

    render json: success_serializer(users_result, :ok, meta), status: :ok
  end

  # GET /users/:id
  def show
    render json: success_serializer(user_with_time_result, :ok), status: :ok
  end

  # POST /users
  def create
    @user = UserService.new(user_params).register

    render json: success_serializer(user_with_time_result, :created), status: :created
  rescue => e
    render json: failed_serializer(e.message, :unprocessable_entity), status: :unprocessable_entity
  end

  # PATCH /users/:id
  def update
    if @user.update(user_params)
      render json: success_serializer(user_with_time_result, :ok), status: :ok
    else
      render json: failed_serializer(@user.errors.full_messages, :unprocessable_entity), status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    user = UserService.new(login_params).login
    token = JsonWebToken.encode(user_id: user.id)
    render json: build_json_login_result(token), status: :ok
  rescue => e
    render json: failed_serializer(e.message, :unprocessable_entity), status: :unprocessable_entity
  end

  private

  def policy_authorize!
    case action_name.to_sym
    when :index
      admin_policy
    when :update, :show
      find_user
      @current_user&.id == @user&.id
    else
      true
    end
  end

  def login_params
    params.permit(:email, :password)
  end

  def user_params
    params.permit(
      :name, :email, :password, :password_confirmation, :limit, :offset
    )
  end

  def index_params
    params.permit(
      :limit, :offset
    )
  end

  def find_user
    @user = User.find_by_id!(params[:id] || @current_user&.id)
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def build_json_login_result(token)
    time = Time.now.localtime + 24.hours.to_i
    {
      token: token,
      exp: time.strftime("%m-%d-%Y %H:%M"),
    }
  end

  def users_result
    @users.map do |user|
      user_with_time_result(user)
    end
  end
end
