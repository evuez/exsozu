defmodule ExSozu.Answer do
  @derive [Poison.Encoder]
  defstruct [:id, :status, :message]
end
