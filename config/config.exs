use Mix.Config

config :exsozu,
  sock_path: "data/sock"

import_config "#{Mix.env}.exs"
