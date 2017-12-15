defmodule ExSozu do
  @moduledoc """
  Provides the main API to interface with Sōzu.
  """

  alias ExSozu.Client

  defdelegate command(command), to: Client
end
