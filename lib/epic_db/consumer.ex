defmodule EpicDb.Consumer do
  use GenServer
  use AMQP

  @doc """
  Starts the consumer.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange       "epic"
  @queue          "epic_queue"
  @routing_key    "#"
  # @queue_error    "#{@queue}_error"
  @prefetch_count 25

  def init(_opts) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)
    # :ok         = Confirm.select(chan)
    Basic.qos(chan, prefetch_count: @prefetch_count)
    Exchange.declare(chan, @exchange, :direct)
    Queue.declare(chan, @queue, durable: true)
    Queue.bind(chan, @queue, @exchange, routing_key: @routing_key)
    Basic.consume(chan, @queue)
    {:ok, chan}
  end

  @doc """
  Spawns a new process to handle messages from rabbitmq.
  """
  def handle_info({payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    spawn fn -> consume(chan, tag, redelivered, payload) end
    {:noreply, chan}
  end

  defp consume(channel, tag, redelivered, payload) do
    EpicDb.Processor.process(EpicDb.Processor, payload)
    Basic.ack channel, tag
  end
end
