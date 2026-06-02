class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

    def authenticate_user!
      unless logged_in?
        flash[:alert] = "Você precisa estar logado para acessar esta página."
        redirect_to new_session_path
      end
    end
end
