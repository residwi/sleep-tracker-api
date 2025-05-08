module Api
  module V1
    class FeedsController < ApplicationController
      def index
        following_ids = Current.user.following.pluck(:id)

        @feeds = SleepRecord.includes(:user)
          .where(user_id: following_ids)
          .where("start_time >= ?", 1.week.ago)
          .order(duration: :desc)
          .select(:id, :start_time, :end_time, :duration, :user_id)

        @pagy, @records = pagy_keyset(@feeds)
        @records = @records.map do |record|
          record.as_json(only: [ :id, :start_time, :end_time, :duration ])
                .merge(user: { id: record.user.id, name: record.user.name })
        end

        json_pagination_response(@records, @pagy)
      end
    end
  end
end
