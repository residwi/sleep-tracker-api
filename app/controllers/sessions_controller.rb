class SessionsController < ApplicationController
  skip_before_action :authenticate, only: :create

  before_action :set_session, only: %i[ destroy ]

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      @session = user.sessions.create!
      response.set_header "X-Session-Token", @session.signed_id

      json_response(data: @session, status: :created)
    else
      json_response(message: "That email or password is incorrect", status: :unauthorized)
    end
  end

  def destroy
    @session.destroy
    head :no_content
  end

  private
    def set_session
      @session = Current.user.sessions.find(params[:id])
    end
end
