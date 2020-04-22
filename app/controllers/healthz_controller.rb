class HealthzController < ActionController::Base
  def index
    render status: 200, json: 'OK'
  end
end
