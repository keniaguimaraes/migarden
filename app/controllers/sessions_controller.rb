class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]

  def new; end

  def create
    if (user = authenticate_user_from_params)
      login(user)
    else
      flash.now[:alert] = t('flash.sessions.invalid_credentials')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    reset_session
    redirect_to new_session_path, notice: t('flash.sessions.logged_out')
  end

  private

  def authenticate_user_from_params
    email = params.dig(:session, :email) || params[:email]
    password = params.dig(:session, :password) || params[:password]
    user = User.find_by(email: email)
    user&.authenticate(password)
  end

  def login(user)
    reset_session
    session[:user_id] = user.id
    redirect_to root_path, notice: "Bem-vindo de volta, #{user.name}!"
  end
end
