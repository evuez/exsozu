defmodule ExSozu.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ExSozu, [], restart: :transient)
    ]

    opts = [strategy: :one_for_one, name: ExSozu.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
