defmodule ExSozu.Macros do
  defmacro defcommand(name, type, args \\ [], do: config) do
    quote do
      def unquote(name)(commands, unquote_splicing(args), opts \\ []) do
        [config(unquote(type), unquote(config), opts) | commands]
      end
    end
  end
end
