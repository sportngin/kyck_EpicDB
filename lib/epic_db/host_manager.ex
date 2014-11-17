defmodule EpicDb.HostManager do
  use GenServer
  require Logger

  ## Client API

  @doc """
  Starts the server.
  """
  def start_link(opts \\ []) do
    es_hosts = Application.get_env(:epic_db, :elasticsearch_hosts)
    |> String.split(",", trim: true)
    rabbit_hosts = Application.get_env(:epic_db, :rabbitmq_hosts)
    |> String.split(",", trim: true)
    GenServer.start_link(__MODULE__, %{elasticsearch: es_hosts, rabbitmq: rabbit_hosts}, opts)
  end

  @doc """
  Returns a host at random
  """
  def random_host(service) do
    GenServer.call(EpicDb.HostManager, {:random_host, service})
  end

  @doc """
  Returns the list of hosts
  """
  def hosts(service) do
    GenServer.call(EpicDb.HostManager, {:hosts, service})
  end

  @doc """
  Syntactic Sugar returns list of elasticsearch servers
  """
  def elasticsearch do
    hosts(:elasticsearch)
  end

  @doc """
  Syntactic Sugar. Returns list of rabbitmq servers
  """
  def rabbitmq do
    hosts(:rabbitmq)
  end

  @doc """
  Adds a host to the list of hosts
  """
  def add_host(host, service) do
    GenServer.cast(EpicDb.HostManager, {:add_host, host, service})
  end

  @doc """
  Removes a host from the list of hosts
  """
  def remove_host(host, service) do
    GenServer.cast(EpicDb.HostManager, {:remove_host, host, service})
  end

  @doc """
  Empties list of hosts
  """
  def remove_all_hosts(service) do
    GenServer.cast(EpicDb.HostManager, {:remove_all_hosts, service})
  end
  def remove_all_hosts do
    GenServer.cast(EpicDb.HostManager, {:remove_all_hosts})
  end

  ## Server Callbacks

  def init(hosts) do
    Logger.debug "Elasticsearch hosts: #{IO.inspect(hosts[:elasticsearch])}"
    Logger.debug "RabbitMQ hosts: #{IO.inspect(hosts[:rabbitmq])}"
    {:ok, hosts}
  end

  def handle_call({:hosts, service}, _from, hosts) do
    {:reply, hosts[service], hosts}
  end
  def handle_call({:random_host, service}, _from, hosts) do
    host = Enum.shuffle(hosts[service]) |> List.first
    {:reply, host, hosts}
  end

  # Hack due to erlang not supporting variable keys
  def handle_cast({:add_host, host, :elasticsearch}, hosts) do
    { :noreply, %{hosts | elasticsearch: [host| hosts[:elasticsearch] ]} }
  end
  def handle_cast({:add_host, host, :rabbitmq}, hosts) do
    { :noreply, %{hosts | rabbitmq: [host| hosts[:rabbitmq] ]} }
  end
  def handle_cast({:remove_host, host, :elasticsearch}, hosts) do
    {:noreply, %{hosts | elasticsearch: List.delete(hosts[:elasticsearch], host)}}
  end
  def handle_cast({:remove_host, host, :rabbitmq}, hosts) do
    {:noreply, %{hosts | rabbitmq: List.delete(hosts[:rabbitmq], host)}}
  end
  def handle_cast({:remove_all_hosts, :elasticsearch}, hosts) do
    {:noreply, %{hosts | elasticsearch: []}}
  end
  def handle_cast({:remove_all_hosts, :rabbitmq}, hosts) do
    {:noreply, %{hosts | rabbitmq: []}}
  end
  def handle_cast({:remove_all_hosts}, _hosts) do
    {:noreply, %{elasticsearch: [], rabbitmq: []}}
  end
end
