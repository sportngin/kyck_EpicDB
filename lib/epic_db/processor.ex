defmodule EpicDb.Processor do
  use GenServer

  ## Client API

  @doc """
  Starts the Processor.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @doc """
  Processes the payload.
  """
  def process(server, payload) do
    GenServer.cast(server, {:process, payload})
  end

  ## Server Callbacks

  def init(_opts) do
    {:ok, self()}
  end

  def handle_cast({:process, payload}, state) do
    event = :jsx.decode(payload)
    IO.puts "Payload: #{payload}"
    {:noreply, state}
  end
end
