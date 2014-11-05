# EpicDB

An Elixir Event Store implementation.

## Getting Started

```bash
# Install Erlang and Elixir
brew update
brew install erlang
brew install elixir

# Clone Repo
git clone git@github.com:KYCK/EpicDB.git
cd EpicDB

# Get dependencies
mix deps.get # The first time you run this it'll ask you to install hex. Say yes.

# Compile, and start iex
iex -S mix
```

Now you'll be in the elixir repl (`iex`).

```elixir
# start the consumer
EpicDb.Consumer.start_link
```

That's it for now. Once you've started the Consumer server, if you generate an event you should see a message saying:

```
Consumed an event: <event json>
```

For ease of generating an event, there is another ruby lib at https://github.com/KYCK/epic_event_generator

```bash
cd ../
git clone git@github.com:KYCK/epic_event_generator.git
cd epic_event_generator
bundle
bin/gen_event
```

If the consumer server is still running, when you run `bin/gen_event` you'll see the event printed to stdout in the `iex` session.

To end the `iex` session hit `CTRL + C` twice.
