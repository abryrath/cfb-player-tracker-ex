defmodule PTracker.Repo do
  use Ecto.Repo,
    otp_app: :p_tracker,
    adapter: Ecto.Adapters.Postgres

end
