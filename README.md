# ExSozu

[![CircleCI](https://circleci.com/gh/evuez/exsozu.svg?style=svg)](https://circleci.com/gh/evuez/exsozu)

An Elixir client for the [Sōzu HTTP reverse proxy](https://github.com/sozu-proxy/sozu).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exsozu` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exsozu, "~> 0.1.0"}]
end
```

## Examples

```elixir
iex> ExSozu.Command.status |> ExSozu.command!
%ExSozu.Answer{data: nil, id: "zd/A+W+ylOHdfIB6", message: "", status: "OK"}
```
