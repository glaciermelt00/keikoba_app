class PagesController < ApplicationController
  def index
    @newests = Post.order(created_at: :desc).take(3) 
  end
end
