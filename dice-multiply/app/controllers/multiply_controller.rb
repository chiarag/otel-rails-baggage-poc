class MultiplyController < ApplicationController
  def multiply
    request.headers.each do |key, value|
      logger.info "Header #{key}: #{value}"
    end

    logger.info "Baggage #{OpenTelemetry::Baggage.raw_entries}"

    random = rand(1..9)
    logger.info "Random is #{random}"
    value = params[:value].to_i
    logger.info "Value is #{value}"
    render json: random * value
  end

end
