
require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
# Require otel-ruby
require 'opentelemetry/sdk'
require 'opentelemetry-metrics-sdk'
require 'opentelemetry/exporter/otlp_metrics'

# default value
#ENV['OTEL_EXPORTER_OTLP_METRICS_ENDPOINT'] = 'http://127.0.0.1:4318/v1/metrics'

# configure SDK with defaults
OpenTelemetry::SDK.configure
otlp_metric_exporter = OpenTelemetry::Exporter::OTLP::MetricsExporter.new
OpenTelemetry.meter_provider.add_metric_reader(otlp_metric_exporter)


class OpenTelemetryMiddleware
  def initialize(app)
    @app = app
    meter = OpenTelemetry.meter_provider.meter("OTEL_METER")

    @counter = meter.create_counter('request_counter', unit: 'request', description: 'counts requests')
    @updown_counter = meter.create_up_down_counter('request_updown_counter', unit: 'request', description: 'counts requests')
    @histogram = meter.create_histogram("request_histogram", unit: "request", description: 'request histogram')
  end

  def call(env)
    @counter.add(1, attributes: {'method' => 'hello'})
    @histogram.record(21, attributes: {'method' => 'hello'})
    @updown_counter.add(1, attributes: {'method' => 'hello'})

    OpenTelemetry.meter_provider.metric_readers.each(&:pull)

    status, headers, response_body = @app.call(env)
    [status, headers, response_body]
  end
end

class App < Sinatra::Base
  set :bind, '0.0.0.0'
  use OpenTelemetryMiddleware

  get '/hello' do
    'Hello World!'
  end

  run! if app_file == $0
end
