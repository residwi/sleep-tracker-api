class UsersController < ApplicationController
  skip_before_action :authenticate, only: [ :index, :show, :followers, :following ]
  before_action :set_user, except: [ :index ]

  def index
    @users = User.select(:id, :name).order(id: :asc)
    @pagy, @records = pagy_keyset(@users)

    json_pagination_response(@records, @pagy)
  end

  def show
    json_response(data: @user)
  end

  def sleep_records
    @sleep_records = @user.sleep_records
      .order(created_at: :desc)
      .select(:id, :start_time, :end_time, :duration)

    @pagy, @records = pagy_keyset(@sleep_records)

    json_pagination_response(@records, @pagy)
  end

  def follow
    if Current.user.follow(@user)
      json_response(message: "Successfully followed user", status: :created)
    else
      json_response(message: "Unable to follow user", status: :unprocessable_entity)
    end
  end

  def unfollow
    Current.user.unfollow(@user)
    head :no_content
  end

  def followers
    @pagy, @records = pagy_keyset(@user.followers.order(created_at: :desc))

    json_pagination_response(@records, @pagy)
  end

  def following
    @pagy, @records = pagy_keyset(@user.following.order(created_at: :desc))

    json_pagination_response(@records, @pagy)
  end

  private

  def set_user
    @user = User.select(:id, :name).find(params[:id])
  end
end
