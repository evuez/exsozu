defmodule ExSozu.Encoder do
  def encode!(command) do
    command
    |> prepare_types
    |> remove_nils
    |> Poison.encode!
  end

  defp prepare_types(command) do
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
