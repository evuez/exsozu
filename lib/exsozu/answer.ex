defmodule ExSozu.Answer do
  @derive [Poison.Encoder]
  defstruct [:id, :status, :message]

  def from_json!(json) do
    answer = Poison.decode!(json, as: %__MODULE__{})

    message = case Poison.decode(answer.message) do
      {:ok, message} -> message
      {:error, _} -> answer.message
    end

    %{answer | message: message}
  end
end
