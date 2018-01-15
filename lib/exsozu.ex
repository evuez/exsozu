defmodule ExSozu do
  @moduledoc """
  Provides the main API to interface with Sōzu and handles the connection.

  ## Answers

  Answers from Sōzu should be handled in a `GenServer.handle_info/2` callback.

  Messages will be in these formats:

      {:answer, %ExSozu.Answer{status: :ok}}
      {:answer, %ExSozu.Answer{status: :processing}}
      {:answer, %ExSozu.Answer{status: :error}}

  ## Reconnections

  ExSozu will try to recover automatically from network errors: if there's a network
  error, ExSozu will try to reconnect after `500` milliseconds. If it fails to do so, it'll
  try again in `500 * 2` milliseconds, then in `500 * 2 * 2` milliseconds, etc.
  """
  use GenServer

  require Logger

  alias ExSozu.Answer
  alias ExSozu.Command
  alias ExSozu.Protocol

  @callback handle_info({:answer, Answer.t}, state :: term) :: term

  defstruct [socket: nil, partial: nil, retries: 0]

  @sock_path Application.fetch_env!(:exsozu, :sock_path)
  @sock_opts [:local, :binary, active: :once]
  @retry_delay 500

  @doc false
  def start_link, do: GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)

  @doc false
  def init(state) do
    case :gen_tcp.connect({:local, @sock_path}, 0, @sock_opts) do
      {:ok, socket} -> {:ok, %{state | socket: socket}}
      {:error, _} ->
        Logger.error "Cannot connect to Sōzu, trying to reconnect..."
        send(self(), :reconnect)
        {:ok, state}
    end
  end

  # API

  @doc """
  Sends `command` to Sōzu.
  """
  @spec command(Command.t) :: {:ok, command_id :: String.t}
  def command(command), do: GenServer.call(__MODULE__, {:command, command})

  @doc """
  Sends a list of commands to Sōzu.
  """
  @spec pipeline([Command.t]) :: {:ok, command_ids :: [String.t]}
  def pipeline(commands), do: GenServer.call(__MODULE__, {:pipeline, commands})

  # Callbacks

  @doc false
  def handle_call({:command, command}, from, state = %{socket: socket}) do
    id = caller_to_id(from)
    command = Protocol.encode!(%{command | id: id})
    :ok = :gen_tcp.send(socket, command)
    {:reply, {:ok, id}, state}
  end

  @doc false
  def handle_call({:pipeline, commands}, from, state = %{socket: socket}) do
    commands = Enum.map(commands, fn command ->
      %{command | id: caller_to_id(from, :unique)}
    end)

    :ok = :gen_tcp.send(socket, commands |> Protocol.encode!())
    {:reply, {:ok, Enum.map(commands, &(&1.id))}, state}
  end

  @doc false
  def handle_info({:tcp, socket, message}, state) do
    :inet.setopts(socket, active: :once)

    {answers, partial} = Protocol.decode!(message, state.partial)

    for answer = %Answer{id: id} <- answers,
      do: id_to_pid(id) |> Process.send({:answer, answer}, [])

    {:noreply, %{state | partial: partial}}
  end

  @doc false
  def handle_info({:tcp_closed, _port}, state) do
    Logger.error "Connection lost, trying to reconnect..."

    send(self(), :reconnect)

    {:noreply, %{state | socket: nil}}
  end

  @doc false
  def handle_info(:reconnect, state = %{retries: retries}) do
    case :gen_tcp.connect({:local, @sock_path}, 0, @sock_opts) do
      {:ok, socket} ->
        Logger.info "Reconnected!"

        {:noreply, %{state | socket: socket, retries: 0}}
      {:error, _} ->
        delay = round(@retry_delay * :math.pow(2, retries))
        Logger.warn "Could not connect to Sōzu, retrying in #{delay / 1000} seconds..."

        Process.send_after(self(), :reconnect, delay)

        {:noreply, %{state | socket: nil, retries: retries + 1}}
    end
  end

  defp caller_to_id(caller), do: :erlang.term_to_binary(caller) |> Base.encode64
  defp caller_to_id(caller, :unique),
    do: :erlang.term_to_binary({caller, make_ref()}) |> Base.encode64

  defp id_to_pid(id) do
    case id |> Base.decode64!() |> :erlang.binary_to_term() do
      {{pid, _ref}, _tag} -> pid
      {pid, _ref} -> pid
    end
  end
end
