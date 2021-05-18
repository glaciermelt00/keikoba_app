class PostsController < ApplicationController
  before_action :logged_in_user, only: %i[new create destroy]
  before_action :correct_user, only: :destroy

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.images.attach(params[:post][:images])
    if @post.save
      flash[:success] = '投稿できました！'
      redirect_to root_url
    else
      render 'new'
    end
  end

  def destroy
    @post.destroy
    flash[:success] = '投稿が削除されました'
    redirect_to request.referer || root_url
  end

  private

  # Strong Parameters
  def post_params
    params.require(:post).permit(:name, :address, :fee, :available_time, :holiday, :phone_number, :url, :content, images: [])
  end

  def correct_user
    @post = current_user.posts.find_by(id: params[:id])
    redirect_to root_url if @post.nil?
  end
end
