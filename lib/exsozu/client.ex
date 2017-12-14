defmodule ExSozu.Client do
  use GenServer

  require Logger

  alias ExSozu.Command
  alias ExSozu.Answer
  alias ExSozu.Protocol

  defstruct [socket: nil, commands: %{}, partial: nil]

  @sock_path Application.fetch_env!(:exsozu, :sock_path)
  @sock_opts [:local, :binary, active: :once]

  def start_link do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, socket} = :gen_tcp.connect({:local, @sock_path}, 0, @sock_opts)
    {:ok, %{state | socket: socket}}
  end

  # API

  @doc """
  Sends `command` to Sozu.

  Answers with the `Processing` status should be handled in a `GenServer.handle_info/2`
  callback. The reply will be in the format `{:processing, %ExSozu.Answer{}}`.
  """
  def command!(command) do
    {:ok, answer} = GenServer.call(__MODULE__, {:send, command})
    answer
  end

  # Callbacks

  def handle_call({:send, command}, from, state = %{socket: socket}) do
    :ok = :gen_tcp.send(socket, Protocol.encode!(command))

    {:noreply, save_client(state, from, command)}
  end

  def handle_info({:tcp, socket, message}, state = %{commands: commands}) do
    :inet.setopts(socket, active: :once)

    {answers, partial} = Protocol.decode!(message, state.partial)

    commands = Enum.reduce(answers, commands, fn
      (answer = %Answer{id: id, status: "PROCESSING"}, commands) ->
        %Command{client: {pid, _}} = Map.get(commands, id)
        Process.send(pid, {:processing, answer}, [])
        commands

      (answer = %Answer{id: id}, commands) ->
        {command, commands} = Map.pop(commands, id)

        case command do
          %Command{client: client} -> GenServer.reply(client, {:ok, answer})
          nil -> Logger.warn "Received unexpected answer: #{inspect answer}"
        end

        commands
    end)

    {:noreply, %{state | commands: commands, partial: partial}}
  end

  def handle_info({:tcp_closed, _port}, state) do
    Logger.warn "Connection closed."

    {:noreply, state}
  end

  # Helpers

  defp save_client(state, client, command = %Command{}) do
    commands = Map.put(state.commands, command.id, %{command | client: client})
    %{state | commands: commands}
  end
end
