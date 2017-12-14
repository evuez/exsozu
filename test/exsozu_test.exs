defmodule ExSozuTest do
  use ExUnit.Case
  alias ExSozu.Command
  alias ExSozu.Answer
  doctest ExSozu

  setup_all do
    Application.ensure_all_started(:exsozu)
    :ok
  end

  test "add_instance/3 and remove_instance/3" do
    assert %Answer{status: "OK"} =
      ExSozu.command!(Command.add_instance("Test", "Test-0", "127.0.0.1", 8001))
    assert %Answer{status: "OK"} =
      ExSozu.command!(Command.remove_instance("Test", "Test-0", "127.0.0.1", 8001))
  end

  test "dump_state/0" do
    assert %Answer{data: %{"data" => %{"applications" =>
      %{"Test" => %{"app_id" => "Test", "sticky_session" => false}},
      "certificates" => %{},
      "http_addresses" => [],
      "http_fronts" => %{"Test" => _},
      "https_addresses" => [], "https_fronts" => %{},
      "instances" => %{"Test" => _}}, "type" => "STATE"}, status: "OK"} =
          ExSozu.command!(Command.dump_state())
  end

  test "list_workers/0 returns a valid command" do
    assert %Answer{data: %{"data" => data, "type" => "WORKERS"}, status: "OK"} =
      ExSozu.command!(Command.list_workers())
    assert [%{"run_state" => "RUNNING"}] = data
  end

  test "save_state/1 and load_state/1" do
    assert %Answer{status: "OK"} =
      ExSozu.command!(Command.save_state("state.json"))
    assert %Answer{status: "OK"} =
      ExSozu.command!(Command.load_state("state.json"))
  end

  test "status/0 returns a valid command" do
    assert %Answer{status: "OK"} = ExSozu.command!(Command.status())
  end

  test "upgrade_master/0" do
    assert %Answer{status: "OK"} = ExSozu.command!(Command.upgrade_master())
    :timer.sleep(4000)
  end
end
