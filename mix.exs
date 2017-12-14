defmodule ExSozu.Mixfile do
  use Mix.Project

  def project do
    [app: :exsozu,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     aliases: aliases()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {ExSozu.Application, []}]
  end

  defp deps do
    [{:poison, "~> 3.1"},
     {:credo, "~> 0.8"}]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end
end
