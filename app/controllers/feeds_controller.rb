class FeedsController < ApplicationController
  def index
    following_ids = Current.user.following.pluck(:id)
    following_ids << Current.user.id

    @feeds = SleepRecord.where(user_id: following_ids)
      .order(created_at: :desc)
      .select(:id, :start_time, :end_time, :duration, :user_id)

    render json: @feeds
  end
end
