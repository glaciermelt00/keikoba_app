class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :set_search

  def set_search
    @q = Post.ransack(params[:q])
    @search_posts = @q.result(distinct: true)
  end

  private

  # ユーザーのログインを確認する
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = 'ログインしてください'
    redirect_to login_url
  end
end
