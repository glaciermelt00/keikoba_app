class FavoritesController < ApplicationController
  before_action :set_post
  before_action :logged_in_user
  before_action :correct_user

  def create
    @favorite = Favorite.new(user_id: current_user.id, post_id: @post.id)
    redirect_to request.referer if @favorite.save
  end

  def destroy
    @favorite = Favorite.find_by(user_id: current_user.id, post_id: @post.id)
    @favorite.destroy
    redirect_to request.referer
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  # current_userかつ投稿者本人以外であることを確認
  def correct_user
    @post = Post.find(params[:post_id])
    redirect_to(root_url) if current_user.id == @post.user_id
  end
end
