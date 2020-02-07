use Mix.Config

config :p_tracker, :ecto_repos, [PTracker.Repo]

config :p_tracker, PTracker.Repo,
  username: "abryrath",
  database: "dev_player_tracker",
  hostname: "localhost"

import_config "#{Mix.env}.exs"
