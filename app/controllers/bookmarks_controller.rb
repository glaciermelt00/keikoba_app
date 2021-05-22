class BookmarksController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user

  def create
    @bookmark = Bookmark.new(user_id: current_user.id, post_id: @post.id)
    redirect_to request.referer if @bookmark.save
  end

  def destroy
    @bookmark = Bookmark.find_by(user_id: current_user.id, post_id: @post.id)
    @bookmark.destroy
    redirect_to request.referer
  end

  private

  # current_userかつ投稿者本人以外であることを確認
  def correct_user
    @post = Post.find(params[:post_id])
    redirect_to(root_url) if current_user.id == @post.user_id
  end
end
