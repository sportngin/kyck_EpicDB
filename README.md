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

Actually we are going to define a template mapping for any index that matches `events*`. This will cover all future timestamped indexes that EpicDB generates when it writes events for a day for the first time.

```bash
curl -XPUT '127.0.0.1:9200/_template/events' -d '{"template":"events*","settings":{"number_of_shards":1,"number_of_replicas":1},"mappings":{"card":{"properties":{"eventTarget":{"type":"string","index":"not_analyzed"},"eventType":{"type":"string","index":"not_analyzed"},"eventTimestamp":{"type":"date"},"eventTrigger":{"type":"nested","properties":{"type":{"type":"string","index":"not_analyzed"},"uuid":{"type":"string","index":"not_analyzed"}}},"data":{"type":"nested","properties":{"uuid":{"type":"string","index":"not_analyzed"},"expiresOn":{"type":"date"},"firstName":{"type":"string","index":"not_analyzed"},"kind":{"type":"string","index":"not_analyzed"},"lastName":{"type":"string","index":"not_analyzed"},"avatar":{"type":"string","index":"not_analyzed"},"birthdate":{"type":"date"},"status":{"type":"string","index":"not_analyzed"}}}}}}}'
```

### Install and Start rabbitmq

Elasticsearch is running in the foreground so you'll need to open a new shell for the following.

```bash
brew update
brew install rabbitmq
rabbitmq-server
```

### Configuration

You'll need to have installed and setup `direnv` ([Home Page](http://direnv.net/), [GitHub](https://github.com/zimbatm/direnv), [Wiki](https://github.com/zimbatm/direnv/wiki)) as per their instructions. Otherwise you'll need to handle your env vars by hand.

There is a `envrc.example` included. This file should be renamed to `.envrc` and modified however you need. Once you've setup `direnv` and got your `.envrc` file inplace, you'll need to tell `direnv` to trust it via `direnv allow .envrc`.

### Run EpicDB

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

Write Tests!!!!!!!!!!!!!!!!
