class BookmarksController < ApplicationController
  before_action :logged_in_user
  before_action :set_post

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

  def set_post
    @post = Post.find(params[:post_id])
  end
end
