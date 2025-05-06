module ApiResponse
  extend ActiveSupport::Concern

  def json_response(data: nil, message: nil, status: :ok)
    response = { data: data }
    response[:message] = message if message.present?

    render json: response, status: status
  end

  def json_error_response(errors, status = :unprocessable_entity)
    render json: {
      data: nil,
      errors: errors.as_json(full_messages: true)
    }, status: status
  end

  def json_pagination_response(records, pagy)
    render json: {
      data: records,
      pagination: {
        next: pagy_keyset_next_url(pagy, absolute: true)
      }
    }
  end
end
