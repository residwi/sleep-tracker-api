class SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: [ :show, :update, :destroy ]

  def index
    @sleep_records = Current.user.sleep_records
      .order(created_at: :desc)
    @pagy, @records = pagy_keyset(@sleep_records)

    render json: {
      data: @records,
      pagination: {
        next: pagy_keyset_next_url(@pagy, absolute: true)
      }
    }
  end

  def create
    @sleep_record = Current.user.sleep_records.new(sleep_record_params)

    if @sleep_record.save
      render json: @sleep_record, status: :created
    else
      render json: { errors: @sleep_record.errors.as_json(full_messages: true) }, status: :unprocessable_entity
    end
  end

  def show
    render json: @sleep_record
  end

  def update
    if @sleep_record.update(sleep_record_params)
      render json: @sleep_record
    else
      render json: { errors: @sleep_record.errors.as_json(full_messages: true) }, status: :unprocessable_entity
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
