module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_sleep_record, only: [ :show, :update, :destroy ]

      def index
        @sleep_records = Current.user.sleep_records
          .order(created_at: :desc)
        @pagy, @records = pagy_keyset(@sleep_records)

        json_pagination_response(@records, @pagy)
      end

      def create
        @sleep_record = Current.user.sleep_records.new(sleep_record_params)

        if @sleep_record.save
          json_response(data: @sleep_record, status: :created)
        else
          json_error_response(@sleep_record.errors, :unprocessable_entity)
        end
      end

      def show
        json_response(data: @sleep_record)
      end

      def update
        if @sleep_record.update(sleep_record_params)
          json_response(data: @sleep_record)
        else
          json_error_response(@sleep_record.errors, :unprocessable_entity)
        end
      end

      def destroy
        @sleep_record.destroy
        head :no_content
      end

      private

      def set_sleep_record
        @sleep_record = Current.user.sleep_records.find(params[:id])
      end

      def sleep_record_params
        params.permit(:start_time, :end_time)
      end
    end
  end
end
