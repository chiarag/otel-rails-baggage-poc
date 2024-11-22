require 'net/http'
require 'opentelemetry-api'

class DiceController < ApplicationController
  def roll
    roll = rand(1..6)

    logger.info "traceid #{OpenTelemetry::Trace.current_span.context.trace_id.unpack1('H*')}"

    # in order to propogate baggage, the least janky way I've found is to attach it as when you build it
    # it returns a brand new context, but does to associate this context with the current or the current entries
    context_with_baggage = OpenTelemetry::Baggage.build { |b| b.set_value('lost_bag', 'where is it?') }
    token = OpenTelemetry::Context.attach(context_with_baggage)

    url = URI.parse("http://localhost:4010/multiply/#{roll}")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url.request_uri)

    response = http.request(request)
    data = JSON.parse(response.body)

    OpenTelemetry::Context.detach(token)

    render json: data
  end
end
