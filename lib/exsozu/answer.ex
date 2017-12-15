defmodule ExSozu.Answer do
  @moduledoc """
  Defines the structure for Sozu's answers.
  """

  @derive [Poison.Encoder]
  defstruct [:id, :status, :message, :data]

  def from_json!(json) do
    answer = Poison.decode!(json, as: %__MODULE__{})

    message = with {:ok, message} <- Poison.decode(answer.message),
                do: message,
                else: (_ -> answer.message)

    %{answer | message: message, status: status(answer.status)}
  end

  defp status("OK"), do: :ok
  defp status("PROCESSING"), do: :processing
  defp status("ERROR"), do: :error
end
