class PostsController < ApplicationController
  before_action :logged_in_user, except: %i[show index]
  before_action :post_owner, only: %i[edit update destroy]

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

  def show
    @post = Post.find(params[:id])
  end

  def index; end

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

  def post_owner
    @post = Post.find(params[:id])
    redirect_to(root_url) unless @post.user == current_user
  end
end
