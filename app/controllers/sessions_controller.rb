class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Bem-vindo de volta, #{user.name}!"
    else
      flash.now[:alert] = "E-mail ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    reset_session
    redirect_to new_session_path, notice: "Você saiu do sistema."
  end
end
