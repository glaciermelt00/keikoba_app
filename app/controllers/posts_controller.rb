class PostsController < ApplicationController
  before_action :logged_in_user, only: %i[new create destroy]
  before_action :correct_user, only: :destroy
  before_action :set_post, only: %i[show edit update]

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

  def show; end

  def edit; end

  def update
    if @post.update(post_params)
      flash[:success] = '記事を更新しました！'
      redirect_to @post
    else
      render 'edit'
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

  # show/edit/updateで@postを事前に仕込んでおく（リファクタリング）
  def set_post
    @post = Post.find(params[:id])
  end
end
