class UsersController < ApplicationController
  skip_before_action :authenticate, only: [ :index, :show, :followers, :following ]
  before_action :set_user, except: [ :index ]

  def index
    @users = User.all
    render json: @users, status: :ok
  end

  def show
    render json: @user, status: :ok
  end

  def follow
    if Current.user.follow(@user)
      render json: { message: "Successfully followed user" }, status: :created
    else
      render json: { error: "Unable to follow user" }, status: :unprocessable_entity
    end
  end

  def unfollow
    Current.user.unfollow(@user)
    head :no_content
  end

  def followers
    @followers = @user.followers
    render json: @followers, status: :ok
  end

  def following
    @following = @user.following
    render json: @following, status: :ok
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
