defmodule EpicDb.Consumer do
  use GenServer
  use AMQP

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange    "epic"
  @queue       "epic_queue"
  @queue_error "#{@queue}_error"

  def init(_opts) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)
    # :ok         = Confirm.select(chan)
    Basic.qos(chan, prefetch_count: 25)
    Exchange.declare(chan, @exchange, :direct)
    Queue.declare(chan, @queue, durable: true)
    Queue.bind(chan, @queue, @exchange, routing_key: "#")
    Basic.consume(chan, @queue)
    {:ok, chan}
  end

  def handle_info({payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    spawn fn -> consume(chan, tag, redelivered, payload) end
    {:noreply, chan}
  end

  defp consume(channel, tag, redelivered, payload) do
    # event = :jsx.decode(payload)
    Basic.ack channel, tag
    IO.puts "Consumed an event: #{payload}"
  end
end
