# EpicDB

An Elixir Event Store implementation.

## Getting Started

```bash
### Install Erlang and Elixir
brew update
brew install erlang
brew install elixir

### Clone Repo
git clone git@github.com:KYCK/EpicDB.git
cd EpicDB

### Get dependencies
mix deps.get # The first time you run this it'll ask you to install hex. Say yes.

### Compile, and start iex
iex -S mix
```

Now you'll be in the elixir repl (`iex`). The `Consumer` and `Processor` `GenServer`s are setup to start automatically so everything will be running.

For ease of generating an event, there is another ruby lib at https://github.com/KYCK/epic_event_generator

```bash
cd ../
git clone git@github.com:KYCK/epic_event_generator.git
cd epic_event_generator
bundle
bin/gen_event
```

If `iex` is still running, when you run `bin/gen_event` the generated event will be stored in elasticsearch.
To end the `iex` session hit `CTRL + C` twice.

## TODO

- [ ] Reconnect to RabbitMQ
- [ ] Startable without RabbitMQ running
- [ ] Allow a list of RabbitMQ servers to connect to
- [ ] Allow a list of Elasticsearch servers to try
- [ ] TESTS
