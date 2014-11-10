defmodule EpicDb.Recorder do
  use GenServer

  ## Client API

  @doc """
  Starts the Recorder
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @doc"""
  Write `data` to the `index` with `type` to elasticsearch.
  """
  def record(type, index \\ "events", payload) do
    # GenServer.cast(EpicDb.Recorder, {:write, payload, index, type})
    GenServer.call(EpicDb.Recorder, {:record, payload, index, type})
  end


  ## Server Callbacks

  def init(_opts) do
    {:ok, []}
  end

  # def handle_cast({:write, data, index, type}, _state) do
  def handle_call({:record, data, index, type}, _from, _state) do
    {:ok, %HTTPoison.Response{status_code: status_code}} =
        url_for(index, type)
        |> HTTPoison.post(data)
    # {:noreply, []}
    if status_code >= 200 and status_code < 300 do
      {:reply, {:ok, :success}, []}
    else
      {:reply, {:ok, :failure}, []}
    end
  end

  ## Private Functions

  defp url_for(index, type) do
    "127.0.0.1:9200/#{index}/#{type}"
  end
end
