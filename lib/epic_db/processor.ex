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
  def process(payload) do
    # GenServer.cast(EpicDb.Processor, {:process, payload})
    GenServer.call(EpicDb.Processor, {:process, payload})
  end

  ## Server Callbacks

  def init(_opts) do
    {:ok, self()}
  end

  # def handle_cast({:process, payload}, _state) do
  def handle_call({:process, payload}, _from, _state) do
    {:ok, status} = :jsx.decode(payload)
    |> find_target
    |> EpicDb.Recorder.record(payload)
    IO.puts "Payload: #{payload}"
    # {:noreply, []}
    {:reply, {:ok, status}, []}
  end

  ## Private Functions

  defp find_target([{"eventTarget", target}|_]) do
    target
  end
  defp find_target([_head|tail]) do
    find_target(tail)
  end
end
