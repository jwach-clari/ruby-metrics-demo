# OpenTelemetry Ruby Metrics Demo

### Running the example

Install gems
```zsh
bundle install
```

Start the server
```zsh
ruby server.rb
```

In a separate terminal window, run the client to make a single request:
```zsh
while true; do ruby client.rb; sleep 5; done;
```

Open Prometheus `http://localhost:9090/graph` and check your metrics.
