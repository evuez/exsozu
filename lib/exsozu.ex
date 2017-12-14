defmodule ExSozu do
  @moduledoc """
  Documentation for ExSozu.
  """

  alias ExSozu.Client

  defdelegate command!(command), to: Client
end
