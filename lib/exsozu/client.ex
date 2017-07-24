defmodule ExSozu.Client do
  use GenServer

  alias ExSozu.Wire

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

  def send(commands), do: GenServer.cast(__MODULE__, {:send, commands})

  def send!(commands) do
    {:ok, response} = send(commands)
    response
  end

  # Callbacks

  def handle_cast({:send, commands}, state = %{socket: socket}) do
    :ok = :gen_tcp.send(socket, Wire.encode!(commands))

    {:noreply, state}
  end

  def handle_call({:recv, ids}, _from, state = %{socket: socket}) do
    {:ok, response} = :gen_tcp.recv(socket, 0)
    {:reply, response, state}
  end
end
