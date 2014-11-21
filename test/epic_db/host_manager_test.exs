defmodule EpicDb.HostManagerTest do
  use ExUnit.Case, async: true
  alias EpicDb.HostManager
  require Logger

  @host_list   ~w/host1 host2 host3/
  @other_list  ~w/other1 other2 other3/

  defp reset_state do
    HostManager.remove_all_services
  end

  defp seed_state do
    reset_state
    HostManager.add_service(:external_service, @host_list)
    HostManager.add_service(:other_service,    @other_list)
  end

  test "add_service/2" do
    reset_state
    assert HostManager.list_services |> Enum.empty?
    HostManager.add_service :test_service
    assert HostManager.list_services == [:test_service]
  end

  test "remove_service/1" do
    seed_state
    assert HostManager.list_services == [:external_service, :other_service]
    HostManager.remove_service(:other_service)
    assert HostManager.list_services == [:external_service]
  end

  test "hosts/1" do
    seed_state
    assert HostManager.hosts(:external_service) == @host_list
  end

  test "add_host/2" do
    seed_state
    HostManager.add_host("four", :external_service)
    assert HostManager.hosts(:external_service) == ["four"|@host_list]
  end

  test "remove_host/2" do
    seed_state
    HostManager.remove_host("host1", :external_service)
    assert HostManager.hosts(:external_service) == ~w/host2 host3/
  end
end
