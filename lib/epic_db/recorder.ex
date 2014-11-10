defmodule EpicDb.Recorder do
  use GenServer
  alias EpicDb.Archiver.EventMessage

  ## Client API

  @doc """
  Starts the Recorder
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @doc """
  Write `data` to the `index` with `type` to elasticsearch.
  """
  def record(event_message, index \\ "events") do
    GenServer.cast(EpicDb.Recorder, {:record, event_message, index})
  end


  ## Server Callbacks

  def init(_opts) do
    {:ok, []}
  end

  def handle_cast({:record, event_message, index}, _state) do
    {:ok, %HTTPoison.Response{status_code: status_code}} =
        EventMessage.target_for(event_message)
        |> url_for(index)
        |> HTTPoison.post(event_message.data)
    if status_code >= 200 and status_code < 300 do
      EventMessage.ack(event_message)
    else
      EventMessage.nack(event_message)
    end
    {:noreply, []}
  end

  ## Private Functions

  defp url_for(type, index) do
    "127.0.0.1:9200/#{index}/#{type}"
  end
end
