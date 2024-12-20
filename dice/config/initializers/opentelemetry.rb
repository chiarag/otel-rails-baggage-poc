# frozen_string_literal: true
require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'dice'
  c.use_all # enables all instrumentation!
end