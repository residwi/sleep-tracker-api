class FeedsController < ApplicationController
  def index
    following_ids = Current.user.following.pluck(:id)
    following_ids << Current.user.id

    @feeds = SleepRecord.where(user_id: following_ids)
      .order(created_at: :desc)
      .select(:id, :start_time, :end_time, :duration, :user_id)

    @pagy, @records = pagy_keyset(@feeds)

    render json: {
      data: @records,
      pagination: {
        next: pagy_keyset_next_url(@pagy, absolute: true)
      }
    }
  end
end
