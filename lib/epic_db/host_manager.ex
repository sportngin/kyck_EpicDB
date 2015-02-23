defmodule EpicDb.HostManager do
  use GenServer
  require Logger

  ## Client API

  @doc """
  Starts the server
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @doc """
  Adds `service_name` and optional `hosts`
  """
  def add_service(service_name, hosts \\ []) do
    GenServer.call(EpicDb.HostManager, {:add_service, service_name, hosts})
  end

  @doc """
  Removes the `service_name` 
  """
  def remove_service(service_name) do
    GenServer.call(EpicDb.HostManager, {:remove_service, service_name})
  end

  @doc """
  List all registered services
  """
  def list_services do
    GenServer.call(EpicDb.HostManager, :list_services)
  end

  @doc """
  Removes all services and hosts
  """
  def remove_all_services do
    GenServer.cast(EpicDb.HostManager, :remove_all_services)
  end

  @doc """
  Returns all known hosts for `service_name`
  """
  def hosts(service_name) do
    GenServer.call(EpicDb.HostManager, {:hosts, service_name})
  end

  @doc """
  Adds `host` to the list of hosts for `service_name`
  """
  def add_host(host, service_name) do
    GenServer.call(EpicDb.HostManager, {:add_host, host, service_name})
  end

  @doc """
  Removes `host` from the list of hosts for `service_name`
  """
  def remove_host(host, service_name) do
    GenServer.call(EpicDb.HostManager, {:remove_host, host, service_name})
  end

  ## Server Callbacks

  def init(_opts) do
    services = Application.get_env(:epic_db, :host_manager_services)
    |> Enum.reduce HashDict.new, fn (service_key, acc) ->

      # TODO: Once exrm provides the ability to configure a release from the environment
      # move this to the relevant location. You can see the github issue here:
      # https://github.com/bitwalker/exrm/issues/90
      hosts = String.upcase("#{service_key}_hosts")
      |> System.get_env
      |> String.split(",", trim: true)
      HashDict.put(acc, service_key, hosts)
    end

    {:ok, services}
  end

  def handle_call({:add_service, name, hosts}, _from, services) do
    new_services = HashDict.put(services, name, hosts)
    {:reply, hosts, new_services}
  end
  def handle_call({:remove_service, name}, _from, services) do
    new_services = HashDict.delete(services, name)
    {:reply, [], new_services}
  end
  def handle_call(:list_services, _from, services) do
    {:reply, HashDict.keys(services), services}
  end
  def handle_call({:hosts, name}, _from, services) do
    {:ok, hosts} = HashDict.fetch(services, name)
    {:reply, hosts, services}
  end
  def handle_call({:add_host, host, name}, _from, services) do
    new_services = HashDict.update!(services, name, &([host|&1]))
    {:reply, new_services[name], new_services}
  end
  def handle_call({:remove_host, host, name}, _from, services) do
    new_services = HashDict.update!(services, name, &(List.delete(&1, host)))
    {:reply, new_services[name], new_services}
  end

  def handle_cast(:remove_all_services, _services) do
    {:noreply, HashDict.new}
  end
end
