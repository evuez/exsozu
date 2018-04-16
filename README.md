# ExSozu

[![CircleCI](https://circleci.com/gh/evuez/exsozu.svg?style=svg)](https://circleci.com/gh/evuez/exsozu)

A resilient Elixir client for the [Sōzu HTTP reverse proxy](https://github.com/sozu-proxy/sozu).

Answers are sent to the calling process via `Process.send/3` and should be handled in a `handle_info/2` or using `receive/1` (the messages are in this format: `{:ansers, %ExSozu.Answer{}}`).

The documentation is available at [https://hexdocs.pm/exsozu](https://hexdocs.pm/exsozu).

## Installation

Add `exsozu` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exsozu, "~> 0.4.0"}]
end
```

## Examples

```elixir
iex> ExSozu.Command.list_workers() |> ExSozu.command()
iex> receive do: (m -> m)
{:answer,
 %ExSozu.Answer{data: %{"data" => [%{"id" => 0, "pid" => 9,
   "run_state" => "RUNNING"}], "type" => "WORKERS"}, id: "oA7iu2qVAL2JNkBg",
 message: "", status: :ok}}
```

Or, using `ExSozu.pipeline/1` to send multiple commands at once:

```elixir
iex> [ExSozu.Command.list_workers(), ExSozu.Command.status()] |> ExSozu.pipeline()
iex> receive do: (m -> m)
{:answer,
 %ExSozu.Answer{data: %{"data" => [%{"id" => 0, "pid" => 9,
   "run_state" => "RUNNING"}], "type" => "WORKERS"}, id: "...",
 message: "", status: :ok}}
iex> receive do: (m -> m)
{:answer,
 %ExSozu.Answer{data: nil,
   id: "...",
   message: "", status: :ok}}
```

I also made a demo interface using ExSozu: [https://github.com/evuez/sozui](https://github.com/evuez/sozui).
