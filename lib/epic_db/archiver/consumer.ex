defmodule EpicDb.Archiver.Consumer do
  use GenServer
  use AMQP
  alias EpicDb.Archiver
  require Logger

  @doc """
  Starts the consumer.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @exchange       "epic"
  @queue          "epic_queue"
  @routing_key    "#"
  @queue_error    "#{@queue}_error"
  @prefetch_count 25

  def init(_opts) do
    {:ok, chan} = connection |> Channel.open
    Basic.qos(chan, prefetch_count: @prefetch_count)
    Exchange.declare(chan, @exchange, :direct)
    Queue.declare(chan, @queue_error, durable: true)
    Queue.declare(chan, @queue, durable: true, arguments: [{"x-dead-letter-exchange", :longstr, ""}, {"x-dead-letter-routing-key", :longstr, @queue_error}])
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

  defp connection do
    connection(refresh_conn_strings)
  end
  defp connection([conn_string|other_conn_strings]) do
    Connection.open(conn_string) |> connection(other_conn_strings)
  end
  defp connection([]) do
    connection
  end
  defp connection({:ok, conn}, _conn_strings) do
    Logger.info "Connected to RabbitMQ."
    link_to_connection(conn)
    conn
  end
  defp connection({:error, :econnrefused}, conn_strings) do
    :timer.sleep(1000)
    Logger.warn "RabbitMQ is not available. Trying again in 1 sec."
    connection(conn_strings)
  end

  defp link_to_connection(conn) do
    %AMQP.Connection{pid: pid} = conn
    Process.link(pid)
  end

  defp consume(channel, tag, redelivered, payload) do
    event_message = Archiver.EventMessage.new(channel, tag, redelivered, payload)
    Archiver.Recorder.Worker.record(event_message)
  end

  defp refresh_conn_strings do
    EpicDb.HostManager.hosts(:rabbitmq)
  end
end
