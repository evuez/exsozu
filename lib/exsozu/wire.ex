defmodule ExSozu.Wire do
  alias ExSozu.Multi

  def encode!(%Multi{actions: actions}) do
    actions
    |> Enum.map(fn {_, action} -> encode!(action) end)
    |> Enum.reverse
  end
  def encode!(command) do
    command = command
              |> encode_types
              |> remove_nils
              |> Poison.encode!

    command <> <<0>>
  end

  defp encode_types(command) do
    command = Map.update!(command, :type, &upcase_atom/1)
    with %{data: %{type: type}} <- command,
      do: put_in(command.data.type, upcase_atom(type))
  end

  defp remove_nils(command) do
    command = with %{proxy_id: nil} <- command, do: Map.delete(command, :proxy_id)
    command = with %{data: nil} <- command, do: Map.delete(command, :data)
    command
  end

  defp upcase_atom(atom), do: atom |> Atom.to_string |> String.upcase
end