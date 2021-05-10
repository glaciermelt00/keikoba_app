class UsersController < ApplicationController
  def index; end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = 'KEIKOBAへようこそ！'
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit; end

  def update; end

  def destroy; end

  def guest; end

  def following; end

  def followers; end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
