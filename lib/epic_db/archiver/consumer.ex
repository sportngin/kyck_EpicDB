defmodule EpicDb.Archiver.Consumer do
  use GenServer
  use AMQP
  alias EpicDb.Archiver

  @doc """
  Starts the consumer.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @exchange       "epic"
  @queue          "epic_queue"
  @routing_key    "#"
  # @queue_error    "#{@queue}_error"
  @prefetch_count 25
  # @conn_string Application.get_env(:epic_db, :amqp_conn_string)

  def init(_opts) do
    {:ok, conn} = Connection.open(conn_string)
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

  ## Private Functions

  defp consume(channel, tag, redelivered, payload) do
    event_message = %Archiver.EventMessage{channel: channel, tag: tag, redelivered: redelivered, data: payload}
    Archiver.Recorder.Worker.record(event_message)
  end

  defp conn_string do
    Application.get_env(:epic_db, :amqp_conn_string)
  end
end
