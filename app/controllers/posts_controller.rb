class PostsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :destroy]

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = '投稿できました！'
      redirect_to 'users/show'
    else
      render root_url
    end
  end

  def destroy; end

  private

  # Strong Parameters
  def post_params
    params.require(:post).permit(:content)
  end
end
