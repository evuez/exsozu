# ExSozu

[![CircleCI](https://circleci.com/gh/evuez/exsozu.svg?style=svg)](https://circleci.com/gh/evuez/exsozu)

An Elixir client for the [Sōzu HTTP reverse proxy](https://github.com/sozu-proxy/sozu).

This is mostly a draft and while it works fine if you just want to order Sōzu do do stuff, you won't be able to get answers from every worker for some commands (though they'll always be logged).
Checkout [this branch](https://github.com/evuez/exsozu/tree/async-messages) for a better handling of Sōzu's answers.

The documentation is available at [https://hexdocs.pm/exsozu](https://hexdocs.pm/exsozu).

## Installation

Add `exsozu` to your list of dependencies in `mix.exs`:

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

I also made an UI using the [async-messages](https://github.com/evuez/exsozu/tree/async-messages) branch [here](https://github.com/evuez/sozui).
