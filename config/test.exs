use Mix.Config

config :p_tracker, PTracker.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  adapter: Ecto.Adapters.Postgres,
  username: "abry",
  database: "test_player_tracker",
  hostname: "localhost"
