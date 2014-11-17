defmodule EpicDb.Archiver.Recorder.Worker do
  use GenServer
  alias EpicDb.Archiver.EventMessage
  require Logger

  ## Client API

  @doc """
  Starts the Recorder
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], [])
  end

  @doc """
  Write `data` to the `index` with `type` to elasticsearch.
  """
  def record(event_message, index \\ "events") do
    :poolboy.transaction(EpicDb.Archiver.Recorder.Worker,
      &(GenServer.call(&1, {:record, event_message, index})))
  end

  ## Server Callbacks

  def init(_opts) do
    {:ok, refresh_hosts_list([])}
  end

  def handle_call({:record, event_message, index}, _from, known_hosts) do
    res = EventMessage.target_for(event_message)
    |> url_for(index, known_hosts)
    |> record_event(event_message.data)
    case res do
      {:ok, 201} ->
        EventMessage.ack event_message
        Logger.debug "ack"
      {:ok, _} ->
        EventMessage.requeue_once event_message
        Logger.debug "requeuing once"
      _ ->
        EventMessage.reject event_message
        Logger.debug "Something went wrong"
    end
    {:reply, [], update_hosts_based_on_response(res, known_hosts)}
  end

  ## Private Functions

  defp update_hosts_based_on_response({:ok, _}, hosts) do
    hosts
  end
  defp update_hosts_based_on_response(_, hosts) do
    [_bad_host|good_hosts] = hosts
    refresh_hosts_list(good_hosts)
  end

  defp refresh_hosts_list(hosts) do
    if Enum.count(hosts) > 0 do
      hosts
    else
      EpicDb.HostManager.elasticsearch
    end
  end

  defp record_event(url, data) do
    HTTPoison.post(url, data)
    |> case do
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:ok, status_code}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      _ ->
        {:error, :unknown}
    end
  end

  defp url_for(type, index, [host|_other_hosts]) do
    url = "#{host}/#{index}/#{type}"
    Logger.debug "URL: #{url}"
    url
  end
end
