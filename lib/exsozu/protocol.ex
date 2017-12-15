defmodule ExSozu.Protocol do
  @moduledoc """
  Provides functions to work with
  [Sōzu's socket message format](https://github.com/sozu-proxy/sozu/tree/master/command).
  """
  alias ExSozu.Answer
  alias ExSozu.Command

  def encode!(command),
    do: Command.to_json!(command) <> <<0>>

  @doc """
  Decodes a message into answers.
  """
  def decode!(message), do: decode!(message, [])
  def decode!(message, nil), do: decode!(message, [])
  def decode!(message, partial) when is_binary(partial),
    do: decode!(partial <> message, [])
  def decode!(message, acc) when is_list(acc) do
    case String.split(message, <<0>>, parts: 2) do
      [partial] -> {Enum.reverse(acc), partial}
      [answer, ""] -> {Enum.reverse([Answer.from_json!(answer) | acc]), nil}
      [answer, rest] ->
        decode!(rest, [Answer.from_json!(answer) | acc])
    end
  end
end
