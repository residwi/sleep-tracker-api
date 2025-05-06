class FeedsController < ApplicationController
  def index
    following_ids = Current.user.following.pluck(:id)
    following_ids << Current.user.id

    @feeds = SleepRecord.where(user_id: following_ids)
      .order(created_at: :desc)
      .select(:id, :start_time, :end_time, :duration, :user_id)

    @pagy, @records = pagy_keyset(@feeds)

    json_pagination_response(@records, @pagy)
  end
end
