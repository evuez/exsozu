defmodule ExSozuTest do
  use ExUnit.Case
  alias ExSozu.Command
  alias ExSozu.Answer
  doctest ExSozu

  test "commands can be sent using pipeline/1" do
    ExSozu.pipeline([Command.dump_state(), Command.list_workers(), Command.status()])

    assert_receive {:answer,
                    %Answer{
                      data: %{
                        "data" => %{
                          "applications" => %{
                            "Test" => %{"app_id" => "Test", "sticky_session" => false}
                          },
                          "certificates" => %{},
                          "http_addresses" => [],
                          "http_fronts" => %{"Test" => _},
                          "https_addresses" => [],
                          "https_fronts" => %{},
                          "instances" => %{"Test" => _}
                        },
                        "type" => "STATE"
                      },
                      status: :ok
                    }}

    assert_receive {:answer,
                    %Answer{data: %{"data" => data, "type" => "WORKERS"}, status: :ok}}

    assert_receive {:answer, %Answer{status: :ok}}
    assert [%{"run_state" => "RUNNING"}] = data
  end

  test "add_instance/4 and remove_instance/4" do
    ExSozu.command(Command.add_instance("Test", "Test-0", "127.0.0.1", 8001))
    ExSozu.command(Command.remove_instance("Test", "Test-0", "127.0.0.1", 8001))

    assert_receive {:answer, %Answer{status: :ok}}
    assert_receive {:answer, %Answer{status: :ok}}
  end

  test "dump_state/0" do
    ExSozu.command(Command.dump_state())

    assert_receive {:answer,
                    %Answer{
                      data: %{
                        "data" => %{
                          "applications" => %{
                            "Test" => %{"app_id" => "Test", "sticky_session" => false}
                          },
                          "certificates" => %{},
                          "http_addresses" => [],
                          "http_fronts" => %{"Test" => _},
                          "https_addresses" => [],
                          "https_fronts" => %{},
                          "instances" => %{"Test" => _}
                        },
                        "type" => "STATE"
                      },
                      status: :ok
                    }}
  end

  test "list_workers/0" do
    ExSozu.command(Command.list_workers())

    assert_receive {:answer,
                    %Answer{data: %{"data" => data, "type" => "WORKERS"}, status: :ok}}

    assert [%{"run_state" => "RUNNING"}] = data
  end

  test "save_state/1 and load_state/1" do
    ExSozu.command(Command.save_state("state.json"))
    ExSozu.command(Command.load_state("state.json"))

    assert_receive {:answer, %Answer{status: :ok}}
    assert_receive {:answer, %Answer{status: :ok}}
  end

  test "status/0" do
    ExSozu.command(Command.status())

    assert_receive {:answer, %Answer{status: :ok}}
  end

  test "upgrade_master/0" do
    ExSozu.command(Command.upgrade_master())

    assert_receive {:answer, %Answer{status: :ok}}
  end
end
