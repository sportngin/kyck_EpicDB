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
  def process(event_message) do
    # GenServer.cast(EpicDb.Processor, {:process, payload})
    GenServer.call(EpicDb.Processor, {:process, event_message})
  end

  ## Server Callbacks

  def init(_opts) do
    {:ok, self()}
  end

  # def handle_cast({:process, payload}, _state) do
  def handle_call({:process, event_message}, _from, _state) do
    recorder_status = EpicDb.Recorder.record(event_message)
    {:reply, recorder_status, []}
  end
end
