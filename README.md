# otel-rails-baggage-poc
A POC with two kinda contrived example rails services to test set up of baggage propagation with distributred services.

Dice rolls a random number between 1 and 6, and then called into Dice Multiply with that value. Returns result * random 1 to 9.
That request is a POST with a URL param. Dice expects Multiply running on 4010.

Dice Service: GET http://localhost:[port]/rolldice

Environment variables are important to start up with so that Open Telemetry enables trace parent and baggage. 

OTEL_TRACES_EXPORTER=console
OTEL_PROPAGATORS=tracecontext,baggage

What I found in this deployment is that the trace parent (transmitted on header `HTTP_TRACEPARENT`) worked without doing anything other than the opentemeletry.rb configuration file.

Baggage was a different story.

Baggage you have to set it - I actually went with build then set but set will build if it isn't there. Where it went sideways is that the return value of that Baggage set value is a context object.

That context object is not connected to the `Current.context` at all. So if you just set baggage, you can't even retrieve it immediately after without providing that context. And with it doesn't transmit the baggage to the next service since it isn't in the current context. It was not the behavior I expected.

It stems from these two blocks of code:
https://github.com/open-telemetry/opentelemetry-ruby/blob/main/api/lib/opentelemetry/baggage.rb#L30-L34
https://github.com/open-telemetry/opentelemetry-ruby/blob/main/api/lib/opentelemetry/context.rb#L153-L157

The current least yucky solution I've found to this is attaching the returned context to the current.

```
OpenTelemetry::Context.attach(context_with_baggage)
```

This allows the baggage to be added to the headers of the request by the OpenTelemetry middleware/wrapper/hooks (whichever word you prefer 🙃)
