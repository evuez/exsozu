defmodule ExSozu.Client do
  use GenServer

  alias ExSozu.Command
  alias ExSozu.Multi
  alias ExSozu.Wire

  defstruct [socket: nil, commands: %{}]

  @sock_path "sozu/bin/command_folder/sock"
  @sock_opts [:local, :binary, active: true]

  def start_link do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, socket} = :gen_tcp.connect({:local, @sock_path}, 0, @sock_opts)
    {:ok, %{state | socket: socket}}
  end

  # API

  def send!(commands) do
    {:ok, answer} = GenServer.call(__MODULE__, {:send, commands})
    answer
  end

  # Callbacks

  def handle_call({:send, commands}, from, state = %{socket: socket}) do
    :ok = :gen_tcp.send(socket, Wire.encode!(commands))

    {:noreply, save_client(state, from, commands)}
  end

  def handle_info({:tcp, _, answer}, state = %{commands: commands}) do
    answer = Wire.decode!(answer)
    {command, commands} = Map.pop(commands, answer.id)

    GenServer.reply(command.client, {:ok, answer})

    {:noreply, %{state | commands: commands}}
  end

  # Helpers

  defp save_client(state, client, command = %Command{}) do
    commands = Map.put(state.commands, command.id, %{command | client: client})
    %{state | commands: commands}
  end
  defp save_client(state, client, %Multi{commands: commands}) do
    commands = commands
               |> Enum.map(fn command -> {command.id, %{command | client: client}} end)
               |> Enum.into(%{})

    %{state | commands: Map.merge(state.commands, commands)}
  end
end
