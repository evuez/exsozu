# ExSozu

An Elixir client for the [Sōzu HTTP reverse proxy](https://github.com/sozu-proxy/sozu).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exsozu` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exsozu, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exsozu](https://hexdocs.pm/exsozu).

## Examples

    iex> ExSozu.start_link
    iex> (ExSozu.multi
          |> ExSozu.Command.dump_state
          |> ExSozu.Command.soft_stop
          |> ExSozu.send)
