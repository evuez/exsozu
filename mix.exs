defmodule ExSozu.Mixfile do
  use Mix.Project

  def project do
    [app: :exsozu,
     version: "0.3.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     description: "A resilient Elixir client for the Sōzu HTTP reverse proxy.",
     source_url: "https://github.com/evuez/exsozu",
     homepage_url: "https://github.com/evuez/exsozu"]
  end

  def application do
    [extra_applications: [:logger],
     mod: {ExSozu.Application, []}]
  end

  defp deps do
    [{:poison, "~> 3.1"},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [licenses: ["MIT"],
     maintainers: ["evuez <helloevuez@gmail.com>"],
     links: %{"GitHub" => "https://github.com/evuez/exsozu"}]
  end
end
