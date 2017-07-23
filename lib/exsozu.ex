defmodule ExSozu do
  @moduledoc """
  Documentation for ExSozu.
  """
  use GenServer

  alias ExSozu.Encoder

  @initial %{socket: nil}
  @sock_path "sozu/bin/command_folder/sock"
  @sock_opts [:local, :binary, active: false]

  def start_link do
    GenServer.start_link(__MODULE__, @initial, name: __MODULE__)
  end

  def init(state) do
    {:ok, socket} = :gen_tcp.connect({:local, @sock_path}, 0, @sock_opts)
    {:ok, %{state | socket: socket}}
  end

  # API

  def multi, do: []

  def send(commands), do: GenServer.call(__MODULE__, {:send, commands})

  def send!(commands) do
    {:ok, response} = send(commands)
    response
  end

  # Callbacks

  def handle_call({:send, commands}, _from, state = %{socket: socket}) do
    commands = Enum.reverse(commands)
               |> Enum.map(&Encoder.encode!/1)
               |> Enum.join(<<0>>)
               |> Kernel.<>(<<0>>)

    :ok = :gen_tcp.send(socket, commands)

    {:ok, response} = :gen_tcp.recv(socket, 0)
    {:reply, response, state}
  end
end
