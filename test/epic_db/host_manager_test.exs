defmodule EpicDb.HostManagerTest do
  use ExUnit.Case, async: true
  alias EpicDb.HostManager

  setup do
    host_list = ["hello", "world", "wat"]
    {:ok, host_list: host_list}
  end

  test "should add a host" do
    HostManager.remove_all_hosts
    host = "home:123"
    HostManager.add_host(host, :elasticsearch)
    [new_host|_tail] = HostManager.hosts(:elasticsearch)
    assert new_host == host
  end

  test "should remove a host", %{host_list: host_list} do
    HostManager.remove_all_hosts
    Enum.each(host_list, &HostManager.add_host(&1, :elasticsearch))
    ["hello", "world"] |> Enum.each(&HostManager.remove_host(&1, :elasticsearch))
    assert HostManager.hosts(:elasticsearch) == ["wat"]
  end

  test "should ignore unknown hosts when removing" do
    HostManager.remove_all_hosts
    HostManager.remove_host("bad host", :elasticsearch)
    assert HostManager.hosts(:elasticsearch) == []
  end

  test "should get a host, hopefully at random", %{host_list: host_list} do
    HostManager.remove_all_hosts
    Enum.each(host_list, &HostManager.add_host(&1, :elasticsearch))
    host = HostManager.random_host :elasticsearch
    assert Enum.any?(host_list, &(&1 == host))
  end

  test "should get all hosts", %{host_list: host_list} do
    HostManager.remove_all_hosts
    Enum.each(host_list, &HostManager.add_host(&1, :elasticsearch))
    assert HostManager.hosts(:elasticsearch) == Enum.reverse(host_list)
  end

  test "should remove all hosts", %{host_list: host_list} do
    Enum.each(host_list, &HostManager.add_host(&1, :elasticsearch))
    HostManager.remove_all_hosts
    assert HostManager.hosts(:elasticsearch) == []
  end
end
