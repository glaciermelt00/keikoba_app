class UsersController < ApplicationController
  include Pagy::Backend

  before_action :logged_in_user, only: %i[edit update destroy]
  before_action :correct_user, only: %i[edit update]
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy(User.where(activated: true))
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated

    @pagy_posts, @posts = pagy(@user.posts, page_param: :page_posts)
    @pagy_favorite_posts, @favorite_posts = pagy(@user.favorite_posts, page_param: :page_favorite_posts)
    @pagy_bookmark_posts, @bookmark_posts = pagy(@user.bookmark_posts, psge_param: :page_bookmark_posts)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = 'アカウントが作成されました！このアカウントを有効にするメールを送信しましたので、ご確認ください。'
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = 'アカウント設定を更新しました！'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    User.find(params[:id]).destroy
    flash[:success] = "ユーザー（#{user.name}）が削除されました"
    redirect_to users_url
  end

  def guest; end

  def following; end

  def followers; end

  private

  # Strong Parameter
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # beforeフィルター

  # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # 管理者かどうか確認
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
