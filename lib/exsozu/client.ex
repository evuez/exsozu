defmodule ExSozu.Client do
  use GenServer

  alias ExSozu.Command
  alias ExSozu.Answer
  alias ExSozu.Protocol

  defstruct [socket: nil, commands: %{}, partial: nil]

  @sock_path Application.fetch_env!(:exsozu, :sock_path)
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
    :ok = :gen_tcp.send(socket, Protocol.encode!(commands))

    {:noreply, save_client(state, from, commands)}
  end

  def handle_info({:tcp, _, message}, state = %{commands: commands, partial: partial}) do
    {answers, partial} = Protocol.decode!(message, partial)

    commands = Enum.reduce(answers, commands, fn(answer = %Answer{id: id}, commands) ->
      {%Command{client: client}, commands} = Map.pop(commands, id)

      GenServer.reply(client, {:ok, answer})

      commands
    end)

    {:noreply, %{state | commands: commands, partial: partial}}
  end

  # Helpers

  defp save_client(state, client, command = %Command{}) do
    commands = Map.put(state.commands, command.id, %{command | client: client})
    %{state | commands: commands}
  end
end
