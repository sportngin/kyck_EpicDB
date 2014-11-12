# EpicDB

An Elixir Event Store implementation.

## Getting Started

To run EpicDB you'll first need elasticsearch and rabbitmq installed and running.

### Install and Start elasticsearch

```bash
brew update
brew install elasticsearch
elasticsearch --config /usr/local/opt/elasticsearch/config/elasticsearch.yml
```

By default, elasticsearch is very good at guessing what types you are sending it. But it treats all strings as something you may want to be able to do full text searches on. This is not something that we need for EpicDB, so we are going to help elasticsearch out and define mappings for different types.

For now the only mapping you'll need is the one for the `card` event type. We can create the `events` index and define a mapping for `cards` in one request.

```bash
curl -XPUT '127.0.0.1:9200/events' -d '{"settings":{"number_of_shards":1,"number_of_replicas":1},"mappings":{"card":{"properties":{"eventTarget":{"type":"string","index":"not_analyzed"},"eventType":{"type":"string","index":"not_analyzed"},"eventTimestamp":{"type":"date"},"eventTrigger":{"type":"nested","properties":{"type":{"type":"string","index":"not_analyzed"},"uuid":{"type":"string","index":"not_analyzed"}}},"data":{"type":"nested","properties":{"uuid":{"type":"string","index":"not_analyzed"},"expiresOn":{"type":"date"},"firstName":{"type":"string","index":"not_analyzed"},"kind":{"type":"string","index":"not_analyzed"},"lastName":{"type":"string","index":"not_analyzed"},"avatar":{"type":"string","index":"not_analyzed"},"birthdate":{"type":"date"},"status":{"type":"string","index":"not_analyzed"}}}}}}}'
```

### Install and Start rabbitmq

Elasticsearch is running in the foreground so you'll need to open a new shell for the following.

```bash
brew update
brew install rabbitmq
rabbitmq-server
```

### Run EpicDB

RabbitMQ is also running in the foreground so you'll need a third shell.

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

Now you'll be in the elixir repl (`iex`). The supervisors are setup to start all the servers/workers/etc. so everything will be running.

### Demoing Locally

For ease of generating an event, there is another ruby lib at https://github.com/KYCK/epic_event_generator. In yet another shell:

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
- [ ] Ability to route bad messages to different queue
